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
    public var memberId: String?
    public var futureStatus: FutureStatus = .none
    public var contracts: [HomeContract] = []
    public var importantMessages: [ImportantMessage] = []
    public var quickActions: [QuickAction] = []
    public var helpCenterFAQModel: HelpCenterFAQModel?
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
    case setMemberId(id: String)
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
                send(.setMemberId(id: memberData.id))
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
        case .fetchFAQ:
            do {
                let faq = try await self.homeService.getFAQ()
                send(.setFAQ(faq: faq))
            } catch {
                self.setError(L10n.General.errorBody, for: .fetchFAQ)
            }
        case .fetchChatNotifications:
            do {
                let chatMessagesState = try await self.homeService.getMessagesState()
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

    public override func reduce(_ state: HomeState, _ action: HomeAction) async -> HomeState {
        var newState = state
        switch action {
        case .setMemberId(let id):
            newState.memberId = id
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

        if state.hasSentOrRecievedAtLeastOneMessage
            || Localization.Locale.currentLocale.value.market != .se
        {
            if state.showChatNotification {
                types.append(.chatNotification(lastMessageTimeStamp: self.state.latestConversationTimeStamp))
            } else {
                types.append(.chat)
            }
        }

        state.toolbarOptionTypes = types
    }
}
