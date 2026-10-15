import AppStateContainer
import Combine
import Contracts
import CrossSell
import Foundation
import Payment
import SwiftUI
import hCore
import hCoreUI

public struct MemberInfo: Codable, Equatable, Sendable {
    let id: String
    let firstName: String
    let isContactInfoUpdateNeeded: Bool

    public init(
        id: String,
        firstName: String,
        isContactInfoUpdateNeeded: Bool
    ) {
        self.id = id
        self.firstName = firstName
        self.isContactInfoUpdateNeeded = isContactInfoUpdateNeeded
    }
}

public enum FutureStatus: Codable, Equatable, Sendable {
    case activeInFuture(inceptionDate: String)
    case pendingSwitchable
    case pendingNonswitchable
    case none
}

@MainActor
@PersistableStore
@Observable
public final class HomeStore: AppStore {
    @ObservationIgnored @Inject private var homeService: HomeClient

    public private(set) var memberContractState: MemberContractState = .loading
    public private(set) var memberInfo: MemberInfo?
    public private(set) var futureStatus: FutureStatus = .none
    public private(set) var contracts: [HomeContract] = []
    public private(set) var importantMessages: [ImportantMessage] = []
    public private(set) var quickActions: [QuickAction] = []
    public private(set) var helpCenterFAQModel: HelpCenterFAQModel?
    public internal(set) var toolbarOptionTypes: [ToolbarOptionType] = []
    public private(set) var showChatNotification: Bool = false
    public private(set) var hasSentOrRecievedAtLeastOneMessage: Bool = false
    public private(set) var latestConversationTimeStamp: Date = Date()
    public private(set) var latestChatTimeStamp: Date = Date()

    @Transient public private(set) var ongoingQuotes: [OngoingQuote] = []
    @Transient public private(set) var hidenImportantMessages: [String] = []
    @Transient public private(set) var isFetchingQuickActions: Bool = false
    @Transient public private(set) var isFetchingFAQ: Bool = false
    @Transient public private(set) var fetchQuickActionsError: String?
    @Transient public private(set) var fetchFAQError: String?
    @Transient public private(set) var fetchMemberStateError: String?

    @ObservationIgnored @Transient private var cancellables = Set<AnyCancellable>()
    private let dismissedQuotes = DismissedOngoingQuotesTracker()

    /// Derived rather than stored so it is current as soon as `quickActions` or the payment data changes.
    public var homeQuickActions: [HomeQuickAction] {
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        let editActions = quickActions.editInsuranceActions
        let tiles: [HomeQuickAction?] = [
            editActions.map(HomeQuickAction.editInsurance),
            quickActions.contains(.changeAddress) ? HomeQuickAction.changeAddress : nil,
            quickActions.contains(.travelInsurance) ? HomeQuickAction.travelCertificate : nil,
            quickActions.sickAbroadDeflection.map(HomeQuickAction.sickAbroad),
            editActions?.quickActions.contains(.upgradeCoverage) == true ? HomeQuickAction.upgradeCoverage : nil,
            HomeQuickAction.inviteFriend,
            paymentStore.paymentData != nil ? HomeQuickAction.upcomingPayment : nil,
        ]
        return tiles.compactMap { $0 }
    }

    public var upcomingRenewalContracts: [HomeContract] {
        contracts.filter { $0.upcomingRenewal != nil }
    }

    public init() {
        let crossSellStore: CrossSellStore = globalAppStateContainer.get()
        crossSellStore.publisher(for: \.hasNewOffer)
            .removeDuplicates()
            .sink { [weak self] _ in self?.updateToolbarTypes() }
            .store(in: &cancellables)

        FeatureFlags.shared.publisher(for: \.data)
            .map(\.isNewConversationFromInboxEnabled)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in self?.updateToolbarTypes() }
            .store(in: &cancellables)

        FeatureFlags.shared.publisher(for: \.data)
            .map(\.isResumingOngoingShopSessionsEnabled)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in Task { await self?.fetchOngoingQuotes() } }
            .store(in: &cancellables)
    }

    public func fetchMemberState() async {
        do {
            let memberData = try await homeService.getMemberState()
            memberContractState = memberData.contractState
            contracts = memberData.contracts
            futureStatus = memberData.futureState
            memberInfo = memberData.memberInfo
            hideDismissedQuotes(forMember: memberData.memberInfo.id)
            fetchMemberStateError = nil
        } catch {
            fetchMemberStateError = L10n.General.errorBody
        }
    }

    public func fetchImportantMessages() async {
        do {
            importantMessages = try await homeService.getImportantMessages()
        } catch {}
    }

    public func fetchQuickActions() async {
        isFetchingQuickActions = true
        do {
            let actions = try await homeService.getQuickActions()
            quickActions = actions
            fetchQuickActionsError = nil
            updateToolbarTypes()
        } catch {
            fetchQuickActionsError = L10n.General.errorBody
        }
        isFetchingQuickActions = false
    }

    public func fetchOngoingQuotes() async {
        guard Dependencies.featureFlags().isResumingOngoingShopSessionsEnabled else {
            ongoingQuotes = []
            return
        }
        ongoingQuotes = (try? await homeService.getOngoingQuotes()) ?? []
        if let memberId = memberInfo?.id { hideDismissedQuotes(forMember: memberId) }
    }

    public func dismissOngoingQuote(id: String) {
        if let memberId = memberInfo?.id {
            dismissedQuotes.dismiss(quoteId: id, forMember: memberId)
        }
        ongoingQuotes.removeAll { $0.id == id }
    }

    private func hideDismissedQuotes(forMember memberId: String) {
        let dismissedIds = dismissedQuotes.dismissedIds(forMember: memberId)
        guard !dismissedIds.isEmpty else { return }
        ongoingQuotes.removeAll { dismissedIds.contains($0.id) }
    }

    public func fetchFAQ() async {
        isFetchingFAQ = true
        do {
            helpCenterFAQModel = try await homeService.getFAQ()
            fetchFAQError = nil
        } catch {
            fetchFAQError = L10n.General.errorBody
        }
        isFetchingFAQ = false
    }

    public func fetchChatNotifications() async {
        do {
            let chatMessagesState = try await homeService.getMessagesState()
            showChatNotification = chatMessagesState.hasNewMessages
            hasSentOrRecievedAtLeastOneMessage = chatMessagesState.hasSentOrRecievedAtLeastOneMessage
            if chatMessagesState.hasNewMessages,
                let latestMessageTimestamp = chatMessagesState.lastMessageTimeStamp
            {
                latestConversationTimeStamp = latestMessageTimestamp
            }
            updateToolbarTypes()
        } catch {}
    }

    public func setMemberContractState(_ state: MemberContractState, contracts: [HomeContract]) {
        memberContractState = state
        self.contracts = contracts
    }

    public func setFutureStatus(_ status: FutureStatus) {
        futureStatus = status
    }

    public func hideImportantMessage(id: String) {
        hidenImportantMessages.append(id)
    }

    public func getImportantMessageToShow() -> [ImportantMessage] {
        importantMessages.filter { !hidenImportantMessages.contains($0.id) }
    }

    public func getImportantMessage(with id: String) -> ImportantMessage? {
        importantMessages.first(where: { $0.id == id })
    }

    public func getAllFAQ() -> [FAQModel]? {
        helpCenterFAQModel?.topics
            .reduce([FAQModel]()) { results, topic in
                var newQuestions: [FAQModel] = results
                newQuestions.append(contentsOf: topic.commonQuestions)
                newQuestions.append(contentsOf: topic.allQuestions)
                return newQuestions
            }
    }

    private func updateToolbarTypes() {
        var types: [ToolbarOptionType] = []
        let crossSellStore: CrossSellStore = globalAppStateContainer.get()

        if crossSellStore.hasNewOffer {
            types.append(.crossSell(hasNewOffer: true))
        } else {
            types.append(.crossSell(hasNewOffer: false))
        }

        if quickActions.hasFirstVet {
            types.append(.firstVet)
        }

        if hasSentOrRecievedAtLeastOneMessage
            || Dependencies.featureFlags().isNewConversationFromInboxEnabled
        {
            types.append(.chat(hasUnread: showChatNotification))
        }

        toolbarOptionTypes = types
    }
}
