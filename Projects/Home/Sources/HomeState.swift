import Apollo
import Chat
import Contracts
import EditCoInsuredShared
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct HomeState: StateProtocol {
    public var memberContractState: MemberContractState = .loading
    public var futureStatus: FutureStatus = .none
    public var contracts: [HomeContract] = []
    public var importantMessages: [ImportantMessage] = []
    public var quickActions: [QuickAction] = []
    public var toolbarOptionTypes: [ToolbarOptionType] = [.chat]
    @Transient(defaultValue: []) var hidenImportantMessages = [String]()
    public var upcomingRenewalContracts: [HomeContract] {
        return contracts.filter { $0.upcomingRenewal != nil }
    }
    public var showChatNotification = false
    public var hasAtLeastOneClaim = false
    public var hasSentOrRecievedAtLeastOneMessage = false

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
    case openFreeTextChat(from: ChatTopicType?)
    case openHelpCenter
    case showNewOffer
    case openFirstVet(partners: [FirstVetPartner])
    case openCoInsured(contractIds: [InsuredPeopleConfig])
    case fetchChatNotifications
    case setChatNotification(hasNew: Bool)
    case setChatNotificationTimeStamp(sentAt: Date)

    case fetchClaims
    case setHasSentOrRecievedAtLeastOneMessage(hasSent: Bool)
    case setHasAtLeastOneClaim(has: Bool)

    case dismissOtherServices
    case hideImportantMessage(id: String)

    case openHelpCenterTopicView(commonTopic: CommonTopic)
    case openHelpCenterQuestionView(question: Question)
    case goToQuickAction(QuickAction)
    case dismissHelpCenter
}

public enum FutureStatus: Codable, Equatable {
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
            do {
                let messages = try await self.homeService.getImportantMessages()
                send(.setImportantMessages(messages: messages))
            } catch {

            }
        case .fetchMemberState:
            do {
                let memberData = try await self.homeService.getMemberState()
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
            do {
                let quickActions = try await self.homeService.getQuickActions()
                send(.setQuickActions(quickActions: quickActions))
            } catch {
                self.setError(L10n.General.errorBody, for: .fetchQuickActions)
            }
        case .fetchChatNotifications:
            do {
                let chatMessagesDates = try await self.homeService.getLastMessagesDates()
                if Dependencies.featureFlags().isConversationBasedMessagesEnabled {
                    let store: ChatStore = globalPresentableStoreContainer.get()
                    let unreadConversations = chatMessagesDates.filter { chatMessagesDate in
                        store.hasNotification(conversationId: chatMessagesDate.key, timeStamp: chatMessagesDate.value)
                    }
                    send(.setChatNotification(hasNew: !unreadConversations.isEmpty))
                    send(.setHasSentOrRecievedAtLeastOneMessage(hasSent: chatMessagesDates.count > 0))
                } else {
                    if let chatMessagesDate = chatMessagesDates.first {
                        let date = chatMessagesDate.value
                        //check if it is auto generated bot message
                        let onlyAutoGeneratedBotMessage =
                            chatMessagesDates.count == 1 && date.addingTimeInterval(2) > Date()

                        if onlyAutoGeneratedBotMessage {
                            send(.setChatNotification(hasNew: false))
                        } else if self.state.latestChatTimeStamp < date {
                            send(.setChatNotification(hasNew: true))
                        } else {
                            send(.setChatNotification(hasNew: false))
                        }
                        send(.setHasSentOrRecievedAtLeastOneMessage(hasSent: !onlyAutoGeneratedBotMessage))
                    } else {
                        send(.setHasSentOrRecievedAtLeastOneMessage(hasSent: false))
                    }
                }
            } catch {}

        case .fetchClaims:
            do {
                let nbOfClaims = try await self.homeService.getNumberOfClaims()
                if nbOfClaims != 0 {
                    send(.setHasAtLeastOneClaim(has: true))
                } else {
                    send(.setHasAtLeastOneClaim(has: false))
                }
            } catch {}
        default:
            break
        }
    }

    public override func reduce(_ state: HomeState, _ action: HomeAction) -> HomeState {
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
            setToolbarTypes(&newState)
        case let .hideImportantMessage(id):
            newState.hidenImportantMessages.append(id)
        case let .setChatNotification(hasNew):
            newState.showChatNotification = hasNew
            setToolbarTypes(&newState)
        case let .setHasAtLeastOneClaim(has):
            newState.hasAtLeastOneClaim = has
            setToolbarTypes(&newState)
        case let .setChatNotificationTimeStamp(sentAt):
            newState.latestChatTimeStamp = sentAt
            newState.showChatNotification = false
            setToolbarTypes(&newState)
        case let .setHasSentOrRecievedAtLeastOneMessage(hasSent):
            newState.hasSentOrRecievedAtLeastOneMessage = hasSent
            setToolbarTypes(&newState)
        default:
            break
        }

        return newState
    }

    private func setToolbarTypes(_ state: inout HomeState) {
        var types: [ToolbarOptionType] = []
        types.append(.newOffer)

        if state.quickActions.hasFirstVet {
            types.append(.firstVet)
        }

        if state.hasAtLeastOneClaim || state.hasSentOrRecievedAtLeastOneMessage
            || Localization.Locale.currentLocale.market != .se
        {
            if state.showChatNotification {
                types.append(.chatNotification)
            } else {
                types.append(.chat)
            }
        }

        state.toolbarOptionTypes = types
    }
}
