import Apollo
import Chat
import Contracts
import EditCoInsuredShared
import Foundation
@preconcurrency import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct HomeState: StateProtocol {
    public var memberContractState: MemberContractState = .loading
    public var futureStatus: FutureStatus = .none
    public var contracts: [HomeContract] = []
    public var importantMessages: [ImportantMessage] = []
    public var quickActions: [QuickAction] = []
    public var toolbarOptionTypes: [ToolbarOptionType] = []
    @Transient(defaultValue: []) var hidenImportantMessages = [String]()
    public var upcomingRenewalContracts: [HomeContract] {
        return contracts.filter { $0.upcomingRenewal != nil }
    }
    public var showChatNotification = false
    public var hasSentOrRecievedAtLeastOneMessage = false
    public var latestConversationTimeStamp = Date()
    public var latestChatTimeStamp = Date()

    func getImportantMessageToShow() -> [ImportantMessage] {
        return importantMessages.filter { importantMessage in
            !hidenImportantMessages.contains(importantMessage.id)
        }
    }

    func getImportantMessage(with id: String) -> ImportantMessage? {
        return importantMessages.first(where: { $0.id == id })
    }

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case fetchMemberState
    case fetchImportantMessages
    case setImportantMessages(messages: [ImportantMessage])
    case setMemberContractState(state: MemberContractState, contracts: [HomeContract])
    case setFutureStatus(status: FutureStatus)
    case fetchUpcomingRenewalContracts
    case openDocument(contractURL: URL)
    case fetchQuickActions
    case setQuickActions(quickActions: [QuickAction])
    case startClaim
    case openFreeTextChat
    case openHelpCenter
    case showNewOffer
    case openFirstVet(partners: [FirstVetPartner])
    case openCoInsured(contractIds: [InsuredPeopleConfig])
    case fetchChatNotifications
    case setChatNotification(hasNew: Bool)
    case setChatNotificationTimeStamp(sentAt: Date)
    case setChatNotificationConversationTimeStamp(date: Date)
    case setHasSentOrRecievedAtLeastOneMessage(hasSent: Bool)

    case dismissOtherServices
    case hideImportantMessage(id: String)

    case openHelpCenterTopicView(commonTopic: CommonTopic)
    case openHelpCenterQuestionView(question: Question)
    case goToQuickAction(QuickAction)
    case dismissHelpCenter
}

public enum FutureStatus: Codable, Equatable, Sendable {
    case activeInFuture(inceptionDate: String)
    case pendingSwitchable
    case pendingNonswitchable
    case none
}

public enum HomeLoadingType: LoadingProtocol {
    case fetchQuickActions
}

public final class HomeStore: LoadingStateStore<HomeState, HomeAction, HomeLoadingType> {
    @Inject var homeService: HomeClient

    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) async {
        switch action {
        case .fetchImportantMessages:
            print("STORE TEST SEND: fetchImportantMessages 3")
            do {
                let messages = try await self.homeService.getImportantMessages()
                print("STORE TEST SEND: fetchImportantMessages setImportantMessages")
                send(.setImportantMessages(messages: messages))
            } catch {

            }
        case .fetchMemberState:
            print("STORE TEST SEND: fetchMemberState 3")
            do {
                let memberData = try await self.homeService.getMemberState()
                print("STORE TEST SEND: fetchMemberState setMemberContractState")
                send(
                    .setMemberContractState(
                        state: memberData.contractState,
                        contracts: memberData.contracts
                    )
                )

                send(.setFutureStatus(status: memberData.futureState))
            } catch _ {
                self.setError(L10n.General.errorBody, for: .fetchQuickActions)
            }
        case .fetchQuickActions:
            print("STORE TEST SEND: fetchQuickActions 3")
            do {
                let quickActions = try await self.homeService.getQuickActions()
                print("STORE TEST SEND: fetchQuickActions setQuickActions")
                send(.setQuickActions(quickActions: quickActions))
            } catch {
                self.setError(L10n.General.errorBody, for: .fetchQuickActions)
            }
        case .fetchChatNotifications:
            print("STORE TEST SEND: fetchChatNotifications 3")
            do {
                let chatMessagesState = try await self.homeService.getMessagesState()
                print("STORE TEST SEND: fetchChatNotifications setChatNotification")
                send(.setChatNotification(hasNew: chatMessagesState.hasNewMessages))
                print("STORE TEST SEND: fetchChatNotifications setHasSentOrRecievedAtLeastOneMessage")
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

    public override func reduce(_ state: HomeState, _ action: HomeAction) async -> HomeState {
        var newState = state
        switch action {
        case .setMemberContractState(let memberState, let contracts):
            newState.memberContractState = memberState
            newState.contracts = contracts
        case .setFutureStatus(let status):
            newState.futureStatus = status
        case .setImportantMessages(let messages):
            newState.importantMessages = messages
        case .fetchQuickActions:
            setLoading(for: .fetchQuickActions)
        case let .setQuickActions(quickActions):
            removeLoading(for: .fetchQuickActions)
            newState.quickActions = quickActions
            print("STORE TEST SEND: SET TOOLBAR TYPES setQuickActions")
            setToolbarTypes(&newState)
        case let .hideImportantMessage(id):
            newState.hidenImportantMessages.append(id)
        case let .setChatNotification(hasNew):
            newState.showChatNotification = hasNew
            print("STORE TEST SEND: SET TOOLBAR TYPES setChatNotification")
            setToolbarTypes(&newState)
        case let .setChatNotificationTimeStamp(sentAt):
            newState.latestChatTimeStamp = sentAt
            newState.showChatNotification = false
            print("STORE TEST SEND: SET TOOLBAR TYPES setChatNotificationTimeStamp")
            setToolbarTypes(&newState)
        case let .setHasSentOrRecievedAtLeastOneMessage(hasSent):
            newState.hasSentOrRecievedAtLeastOneMessage = hasSent
            print("STORE TEST SEND: SET TOOLBAR TYPES setHasSentOrRecievedAtLeastOneMessage")
            setToolbarTypes(&newState)
        case let .setChatNotificationConversationTimeStamp(timeStamp):
            newState.latestConversationTimeStamp = timeStamp
            print("STORE TEST SEND: SET TOOLBAR TYPES setChatNotificationConversationTimeStamp")
            setToolbarTypes(&newState)
        default:
            break
        }

        return newState
    }

    private func setToolbarTypes(_ state: inout HomeState) {
        print("STORE TEST SEND: SET TOOLBAR TYPES")
        var types: [ToolbarOptionType] = []
        types.append(.newOffer)

        if state.quickActions.hasFirstVet {
            types.append(.firstVet)
        }

        if state.hasSentOrRecievedAtLeastOneMessage {
            if state.showChatNotification {
                types.append(.chatNotification(lastMessageTimeStamp: self.state.latestConversationTimeStamp))
            } else {
                types.append(.chat)
            }
        }

        state.toolbarOptionTypes = types
    }
}
