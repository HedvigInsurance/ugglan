import AppStateContainer
import Combine
import CrossSell
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct MemberInfo: Codable, Equatable, Sendable {
    let id: String
    let isContactInfoUpdateNeeded: Bool

    public init(
        id: String,
        isContactInfoUpdateNeeded: Bool
    ) {
        self.id = id
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
public final class HomeStore: AppStore {
    @Inject private var homeService: HomeClient

    @Published public private(set) var memberContractState: MemberContractState = .loading
    @Published public private(set) var memberInfo: MemberInfo?
    @Published public private(set) var hasMissedCharge: Bool = false
    @Published public private(set) var futureStatus: FutureStatus = .none
    @Published public private(set) var contracts: [HomeContract] = []
    @Published public private(set) var importantMessages: [ImportantMessage] = []
    @Published public private(set) var quickActions: [QuickAction] = []
    @Published public private(set) var helpCenterFAQModel: HelpCenterFAQModel?
    @Published public internal(set) var toolbarOptionTypes: [ToolbarOptionType] = []
    @Published public private(set) var showChatNotification: Bool = false
    @Published public private(set) var hasSentOrRecievedAtLeastOneMessage: Bool = false
    @Published public private(set) var latestConversationTimeStamp: Date = Date()
    @Published public private(set) var latestChatTimeStamp: Date = Date()

    @Transient @Published public private(set) var hidenImportantMessages: [String] = []
    @Transient @Published public private(set) var isFetchingQuickActions: Bool = false
    @Transient @Published public private(set) var isFetchingFAQ: Bool = false
    @Transient @Published public private(set) var fetchQuickActionsError: String?
    @Transient @Published public private(set) var fetchFAQError: String?
    @Transient @Published public private(set) var fetchMemberStateError: String?

    private var cancellables = Set<AnyCancellable>()

    public var upcomingRenewalContracts: [HomeContract] {
        contracts.filter { $0.upcomingRenewal != nil }
    }

    public init() {
        let crossSellStore: CrossSellStore = globalAppStateContainer.get()
        crossSellStore.$hasNewOffer
            .removeDuplicates()
            .sink { [weak self] _ in self?.updateToolbarTypes() }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: .didChargeOutstandingPayment)
            .sink { [weak self] _ in self?.hasMissedCharge = false }
            .store(in: &cancellables)

        FeatureFlags.shared.$data
            .map(\.isNewConversationFromInboxEnabled)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in self?.updateToolbarTypes() }
            .store(in: &cancellables)
    }

    public func fetchMemberState() async {
        do {
            let memberData = try await homeService.getMemberState()
            memberContractState = memberData.contractState
            contracts = memberData.contracts
            futureStatus = memberData.futureState
            memberInfo = memberData.memberInfo
            fetchMemberStateError = nil
        } catch {
            fetchMemberStateError = L10n.General.errorBody
        }
    }

    public func fetchMissedCharge() async {
        hasMissedCharge = (try? await homeService.getHasMissedCharge()) ?? false
    }

    public func fetchImportantMessages() async {
        do {
            importantMessages = try await homeService.getImportantMessages()
        } catch {}
    }

    public func fetchQuickActions() async {
        isFetchingQuickActions = true
        do {
            quickActions = try await homeService.getQuickActions()
            fetchQuickActionsError = nil
            updateToolbarTypes()
        } catch {
            fetchQuickActionsError = L10n.General.errorBody
        }
        isFetchingQuickActions = false
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

    public func clearMissedCharge() {
        hasMissedCharge = false
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
