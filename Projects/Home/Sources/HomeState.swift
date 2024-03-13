import Apollo
import Contracts
import EditCoInsured
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct HomeState: StateProtocol {
    public var memberContractState: MemberContractState = .loading
    public var futureStatus: FutureStatus = .none
    public var contracts: [Contract] = []
    public var importantMessages: [ImportantMessage] = []
    public var quickAction: [QuickAction] = []
    public var toolbarOptionTypes: [ToolbarOptionType] = [.chat]
    @Transient(defaultValue: []) var hidenImportantMessages = [String]()
    public var upcomingRenewalContracts: [Contract] {
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
    case setMemberContractState(state: MemberContractState, contracts: [Contract])
    case setFutureStatus(status: FutureStatus)
    case fetchUpcomingRenewalContracts
    case openDocument(contractURL: URL)
    case fetchQuickActions
    case setQuickActions(quickActions: [QuickAction])
    case startClaim
    case openFreeTextChat(from: ChatTopicType?)
    case openHelpCenter
    case showNewOffer
    case openQuickActionDetail(quickActions: QuickAction, fromOtherServices: Bool)
    case openCoInsured(contractIds: [InsuredPeopleConfig])
    case fetchChatNotifications
    case setChatNotification(hasNew: Bool)
    case setChatNotificationTimeStamp(sentAt: Date)

    case fetchClaims
    case setHasSentOrRecievedAtLeastOneMessage(hasSent: Bool)
    case setHasAtLeastOneClaim(has: Bool)

    case dismissOtherServices
    case hideImportantMessage(id: String)
    case openContractCertificate(url: URL, title: String)

    case openHelpCenterTopicView(commonTopic: CommonTopic)
    case openHelpCenterQuestionView(question: Question)
    case goToQuickAction(QuickAction)
    case goToURL(url: URL)
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
    @Inject var homeService: HomeService

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
                if ApplicationContext.shared.isDemoMode {
                    send(.setQuickActions(quickActions: []))
                } else {
                    self.setError(L10n.General.errorBody, for: .fetchQuickActions)
                }
            }
        case .fetchQuickActions:
            do {
                let quickActions = try await self.homeService.getQuickActions()
                send(.setQuickActions(quickActions: quickActions))
            } catch {
                if ApplicationContext.shared.isDemoMode {
                    send(.setQuickActions(quickActions: []))
                } else {
                    self.setError(L10n.General.errorBody, for: .fetchQuickActions)
                }
            }
        case .fetchChatNotifications:
            do {
                let chatMessagesDates = try await self.homeService.getLastMessagesDates()
                if let date = chatMessagesDates.first {
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
            newState.quickAction = quickActions
            setAllQuickActions(&newState)
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

    private func setAllQuickActions(_ state: inout HomeState) {
        var allQuickActions = [QuickAction]()
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contracts = contractStore.state.activeContracts

        if Dependencies.featureFlags().isMovingFlowEnabled
            && !contracts.filter({ $0.supportsAddressChange }).isEmpty
        {
            allQuickActions.append(.moving())
        }
        allQuickActions.append(.payments())

        if Dependencies.featureFlags().isEditCoInsuredEnabled
            && !contracts.filter({ $0.showEditCoInsuredInfo }).isEmpty
        {
            allQuickActions.append(.editCoInsured())
        }

        if Dependencies.featureFlags().isTravelInsuranceEnabled
            && !contracts.filter({ $0.supportsTravelCertificate }).isEmpty
        {
            allQuickActions.append(.travelInsurance())
        }
        allQuickActions.append(contentsOf: state.quickAction)
        state.quickAction = allQuickActions
        setToolbarTypes(&state)
    }

    private func setToolbarTypes(_ state: inout HomeState) {
        var types: [ToolbarOptionType] = []
        types.append(.newOffer)

        if state.quickAction.vetQuickAction != nil {
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

extension QuickAction {
    public static func travelInsurance() -> QuickAction {
        let quickAction = QuickAction(
            id: "travelInsurance",
            displayTitle: L10n.hcQuickActionsTravelCertificate,
            displaySubtitle: L10n.hcQuickActionsTravelCertificateSubtitle,
            layout: nil
        )
        return quickAction
    }

    public static func moving() -> QuickAction {
        return QuickAction(
            id: "moving_flow",
            displayTitle: L10n.hcQuickActionsChangeAddressTitle,
            displaySubtitle: L10n.hcQuickActionsChangeAddressSubtitle,
            layout: nil
        )
    }

    public static func editCoInsured() -> QuickAction {
        QuickAction(
            id: "edit_coinsured",
            displayTitle: L10n.hcQuickActionsCoInsuredTitle,
            displaySubtitle: L10n.hcQuickActionsCoInsuredSubtitle,
            layout: nil
        )
    }

    public static func payments() -> QuickAction {
        QuickAction(
            id: "payments",
            displayTitle: L10n.hcQuickActionsPaymentsTitle,
            displaySubtitle: L10n.hcQuickActionsPaymentsSubtitle,
            layout: nil
        )
    }
}
