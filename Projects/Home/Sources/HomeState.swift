import Apollo
import Combine
import CrossSell
import Foundation
@preconcurrency import PresentableStore
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

public struct HomeState: StateProtocol {
    public var memberContractState: MemberContractState = .loading
    public var memberInfo: MemberInfo?
    public var futureStatus: FutureStatus = .none
    public var contracts: [HomeContract] = []
    public var importantMessages: [ImportantMessage] = []
    public var quickActions: [QuickAction] = []
    public var helpCenterFAQModel: HelpCenterFAQModel?
    public var toolbarOptionTypes: [ToolbarOptionType] = []
    @Transient(defaultValue: []) var hidenImportantMessages = [String]()

    public var upcomingRenewalContracts: [HomeContract] {
        contracts.filter { $0.upcomingRenewal != nil }
    }

    public var showChatNotification = false
    public var hasSentOrRecievedAtLeastOneMessage = false
    public var latestConversationTimeStamp = Date()
    public var latestChatTimeStamp = Date()

    func getImportantMessageToShow() -> [ImportantMessage] {
        importantMessages.filter { importantMessage in
            !hidenImportantMessages.contains(importantMessage.id)
        }
    }

    func getImportantMessage(with id: String) -> ImportantMessage? {
        importantMessages.first(where: { $0.id == id })
    }

    public func getAllFAQ() -> [FAQModel]? {
        helpCenterFAQModel?.topics
            .reduce(
                [FAQModel](),
                { results, topic in
                    var newQuestions: [FAQModel] = results
                    newQuestions.append(contentsOf: topic.commonQuestions)
                    newQuestions.append(contentsOf: topic.allQuestions)
                    return newQuestions
                }
            )
    }

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case fetchMemberState
    case fetchImportantMessages
    case setImportantMessages(messages: [ImportantMessage])
    case setMemberContractState(state: MemberContractState, contracts: [HomeContract])
    case setMemberInfo(memberInfo: MemberInfo)
    case setFutureStatus(status: FutureStatus)
    case openDocument(contractURL: URL)
    case fetchQuickActions
    case setQuickActions(quickActions: [QuickAction])
    case fetchFAQ
    case setFAQ(faq: HelpCenterFAQModel)
    case fetchChatNotifications
    case setChatNotification(hasNew: Bool)
    case setChatNotificationConversationTimeStamp(date: Date)
    case setHasSentOrRecievedAtLeastOneMessage(hasSent: Bool)
    case hideImportantMessage(id: String)
    case recommendedProductUpdated
}

public enum FutureStatus: Codable, Equatable, Sendable {
    case activeInFuture(inceptionDate: String)
    case pendingSwitchable
    case pendingNonswitchable
    case none
}

public enum HomeLoadingType: LoadingProtocol {
    case fetchQuickActions
    case fetchFAQ
}

public final class HomeStore: LoadingStateStore<HomeState, HomeAction, HomeLoadingType> {
    @Inject var homeService: HomeClient
    private var newOfferSubscription: AnyCancellable?
    required init() {
        super.init()
        let store: CrossSellStore = globalPresentableStoreContainer.get()
        newOfferSubscription = store.stateSignal.map(\.hasNewOffer).removeDuplicates()
            .sink { [weak self] _ in
                self?.send(.recommendedProductUpdated)
            }
    }

    override public func effects(
        _: @escaping () -> HomeState,
        _ action: HomeAction
    ) async {
        switch action {
        case .fetchImportantMessages:
            do {
                let messages = try await homeService.getImportantMessages()
                send(.setImportantMessages(messages: messages))
            } catch {}
        case .fetchMemberState:
            do {
                let memberData = try await homeService.getMemberState()
                send(
                    .setMemberContractState(
                        state: memberData.contractState,
                        contracts: memberData.contracts
                    )
                )

                send(.setFutureStatus(status: memberData.futureState))
                send(.setMemberInfo(memberInfo: memberData.memberInfo))
            } catch _ {
                setError(L10n.General.errorBody, for: .fetchQuickActions)
            }
        case .fetchQuickActions:
            do {
                let quickActions = try await homeService.getQuickActions()
                send(.setQuickActions(quickActions: quickActions))
            } catch {
                setError(L10n.General.errorBody, for: .fetchQuickActions)
            }
        case .fetchFAQ:
            do {
                let faq = try await homeService.getFAQ()
                send(.setFAQ(faq: faq))
            } catch {
                setError(L10n.General.errorBody, for: .fetchFAQ)
            }
        case .fetchChatNotifications:
            do {
                let chatMessagesState = try await homeService.getMessagesState()
                send(.setChatNotification(hasNew: chatMessagesState.hasNewMessages))
                send(
                    .setHasSentOrRecievedAtLeastOneMessage(
                        hasSent: chatMessagesState.hasSentOrRecievedAtLeastOneMessage
                    )
                )
                if chatMessagesState.hasNewMessages, let latestMessageTimestamp = chatMessagesState.lastMessageTimeStamp
                {
                    send(.setChatNotificationConversationTimeStamp(date: latestMessageTimestamp))
                }
            } catch {}
        default:
            break
        }
    }

    override public func reduce(_ state: HomeState, _ action: HomeAction) async -> HomeState {
        var newState = state
        switch action {
        case let .setMemberInfo(memberInfo):
            newState.memberInfo = memberInfo
        case let .setMemberContractState(memberState, contracts):
            newState.memberContractState = memberState
            newState.contracts = contracts
        case let .setFutureStatus(status):
            newState.futureStatus = status
        case let .setImportantMessages(messages):
            newState.importantMessages = messages
        case .fetchQuickActions:
            setLoading(for: .fetchQuickActions)
        case let .setQuickActions(quickActions):
            removeLoading(for: .fetchQuickActions)
            newState.quickActions = quickActions
            setToolbarTypes(&newState)
        case .fetchFAQ:
            setLoading(for: .fetchFAQ)
        case let .setFAQ(faq):
            removeLoading(for: .fetchFAQ)
            newState.helpCenterFAQModel = faq
        case let .hideImportantMessage(id):
            newState.hidenImportantMessages.append(id)
        case let .setChatNotification(hasNew):
            newState.showChatNotification = hasNew
            setToolbarTypes(&newState)
        case let .setHasSentOrRecievedAtLeastOneMessage(hasSent):
            newState.hasSentOrRecievedAtLeastOneMessage = hasSent
            setToolbarTypes(&newState)
        case let .setChatNotificationConversationTimeStamp(timeStamp):
            newState.latestConversationTimeStamp = timeStamp
            setToolbarTypes(&newState)
        case .recommendedProductUpdated:
            setToolbarTypes(&newState)
        default:
            break
        }

        return newState
    }

    private func setToolbarTypes(_ state: inout HomeState) {
        var types: [ToolbarOptionType] = []
        types.append(.yearInReview)
        let crossSellStore: CrossSellStore = globalPresentableStoreContainer.get()

        if crossSellStore.state.hasNewOffer {
            types.append(.crossSell(hasNewOffer: true))
        } else {
            types.append(.crossSell(hasNewOffer: false))
        }

        if state.quickActions.hasFirstVet {
            types.append(.firstVet)
        }

        if state.hasSentOrRecievedAtLeastOneMessage {
            if state.showChatNotification {
                types.append(.chat(hasUnread: true))
            } else {
                types.append(.chat(hasUnread: false))
            }
        }

        state.toolbarOptionTypes = types
    }
}
