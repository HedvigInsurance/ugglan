import Apollo
import Contracts
import EditCoInsured
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct HomeState: StateProtocol {
    public var memberStateData: MemberStateData = .init(state: .loading, name: nil)
    public var futureStatus: FutureStatus = .none
    public var contracts: [Contract] = []
    public var importantMessages: [ImportantMessage] = []
    public var commonClaims: [CommonClaim] = []
    public var allCommonClaims: [CommonClaim] = []
    public var toolbarOptionTypes: [ToolbarOptionType] = [.chat]
    @Transient(defaultValue: []) var hidenImportantMessages = [String]()
    public var upcomingRenewalContracts: [Contract] {
        return contracts.filter { $0.upcomingRenewal != nil }
    }
    public var showChatNotification = false
    public var hasAtLeastOneClaim = false
    public var hasSentOrRecievedAtLeastOneMessage = false

    public var latestChatTimeStamp = Date()

    public var hasFirstVet: Bool {
        return commonClaims.first(where: { $0.id == "30" || $0.id == "31" || $0.id == "32" }) != nil
    }

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
    case setMemberContractState(state: MemberStateData, contracts: [Contract])
    case setFutureStatus(status: FutureStatus)
    case fetchUpcomingRenewalContracts
    case openDocument(contractURL: URL)
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case startClaim
    case openFreeTextChat(from: ChatTopicType?)
    case openHelpCenter
    case showNewOffer
    case openCommonClaimDetail(commonClaim: CommonClaim, fromOtherServices: Bool)
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
    case goToQuickAction(CommonClaim)
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
    case fetchCommonClaim
}

public final class HomeStore: LoadingStateStore<HomeState, HomeAction, HomeLoadingType> {
    @Inject var homeService: HomeService

    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) -> FiniteSignal<HomeAction>? {
        switch action {
        case .fetchImportantMessages:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let messages = try await self.homeService.getImportantMessages()
                        callback(.value(.setImportantMessages(messages: messages)))
                    } catch {

                    }
                    callback(.end)
                }
                return disposeBag
            }
        case .fetchMemberState:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let memberData = try await self.homeService.getMemberState()
                        callback(
                            .value(
                                .setMemberContractState(
                                    state: .init(
                                        state: memberData.contractState,
                                        name: memberData.firstName
                                    ),
                                    contracts: memberData.contracts
                                )
                            )
                        )
                        callback(.value(.setFutureStatus(status: memberData.futureState)))
                        callback(.end)
                    } catch let error {
                        if ApplicationContext.shared.isDemoMode {
                            callback(.value(.setCommonClaims(commonClaims: [])))
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchCommonClaim)
                        }
                        callback(.end(error))
                    }

                }
                return disposeBag
            }
        case .fetchCommonClaims:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let commonClaims = try await self.homeService.getCommonClaims()
                        callback(.value(.setCommonClaims(commonClaims: commonClaims)))
                        callback(.end)
                    } catch {
                        if ApplicationContext.shared.isDemoMode {
                            callback(.value(.setCommonClaims(commonClaims: [])))
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchCommonClaim)
                        }
                        callback(.end(error))
                    }
                }
                return disposeBag
            }
        case .fetchChatNotifications:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let chatMessagesDates = try await self.homeService.getLastMessagesDates()
                        if let date = chatMessagesDates.first {
                            //check if it is auto generated bot message
                            let onlyAutoGeneratedBotMessage =
                                chatMessagesDates.count == 1 && date.addingTimeInterval(2) > Date()

                            if onlyAutoGeneratedBotMessage {
                                callback(.value(.setChatNotification(hasNew: false)))
                            } else if self.state.latestChatTimeStamp < date {
                                callback(.value(.setChatNotification(hasNew: true)))
                            } else {
                                callback(.value(.setChatNotification(hasNew: false)))
                            }

                            callback(
                                .value(.setHasSentOrRecievedAtLeastOneMessage(hasSent: !onlyAutoGeneratedBotMessage))
                            )
                        }
                        callback(.end)
                    } catch {}
                }
                return disposeBag
            }

        case .fetchClaims:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let nbOfClaims = try await self.homeService.getNumberOfClaims()
                        if nbOfClaims != 0 {
                            callback(.value(.setHasAtLeastOneClaim(has: true)))
                        } else {
                            callback(.value(.setHasAtLeastOneClaim(has: false)))
                        }
                    } catch {}
                    callback(.end)
                }
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: HomeState, _ action: HomeAction) -> HomeState {
        var newState = state

        switch action {
        case .setMemberContractState(let memberState, let contracts):
            newState.memberStateData = memberState
            newState.contracts = contracts
        case .setFutureStatus(let status):
            newState.futureStatus = status
        case .setImportantMessages(let messages):
            newState.importantMessages = messages
        case .fetchCommonClaims:
            setLoading(for: .fetchCommonClaim)
        case let .setCommonClaims(commonClaims):
            removeLoading(for: .fetchCommonClaim)
            newState.commonClaims = commonClaims
            setAllCommonClaims(&newState)
        case let .hideImportantMessage(id):
            newState.hidenImportantMessages.append(id)
        case let .setChatNotification(hasNew):
            newState.showChatNotification = hasNew
            setAllCommonClaims(&newState)
        case let .setHasAtLeastOneClaim(has):
            newState.hasAtLeastOneClaim = has
            setAllCommonClaims(&newState)
        case let .setChatNotificationTimeStamp(sentAt):
            newState.latestChatTimeStamp = sentAt
            newState.showChatNotification = false
            setAllCommonClaims(&newState)
        case let .setHasSentOrRecievedAtLeastOneMessage(hasSent):
            newState.hasSentOrRecievedAtLeastOneMessage = hasSent
            setAllCommonClaims(&newState)
        default:
            break
        }

        return newState
    }

    private func setAllCommonClaims(_ state: inout HomeState) {
        var allCommonClaims = [CommonClaim]()

        allCommonClaims.append(.changeBank())

        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contracts = contractStore.state.activeContracts

        if Dependencies.featureFlags().isEditCoInsuredEnabled
            && !contracts.filter({ $0.showEditCoInsuredInfo }).isEmpty
        {
            allCommonClaims.append(.editCoInsured())
        }

        if Dependencies.featureFlags().isMovingFlowEnabled
            && !contracts.filter({ $0.supportsAddressChange }).isEmpty
        {
            allCommonClaims.append(.moving())
        }
        if Dependencies.featureFlags().isTravelInsuranceEnabled
            && !contracts.filter({ $0.supportsTravelCertificate }).isEmpty
        {
            allCommonClaims.append(.travelInsurance())
        }
        allCommonClaims.append(contentsOf: state.commonClaims)
        state.allCommonClaims = allCommonClaims

        var types: [ToolbarOptionType] = []
        types.append(.newOffer)

        if state.hasFirstVet {
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

public enum MemberContractState: String, Codable, Equatable {
    case terminated
    case future
    case active
    case loading
}

extension CommonClaim {
    public static func travelInsurance() -> CommonClaim {
        let titleAndBulletPoint = CommonClaim.Layout.TitleAndBulletPoints(
            color: "",
            buttonTitle: L10n.TravelCertificate.getTravelCertificateButton,
            title: "",
            bulletPoints: []
        )
        let emergency = CommonClaim.Layout.Emergency(title: L10n.TravelCertificate.description, color: "")
        let layout = CommonClaim.Layout(titleAndBulletPoint: titleAndBulletPoint, emergency: emergency)
        let commonClaim = CommonClaim(
            id: "travelInsurance",
            icon: nil,
            imageName: "travelCertificate",
            displayTitle: L10n.TravelCertificate.cardTitle,
            layout: layout
        )
        return commonClaim
    }

    public static func moving() -> CommonClaim {
        return CommonClaim(
            id: "moving_flow",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.InsuranceDetails.changeAddressButton,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }

    public static func editCoInsured() -> CommonClaim {
        CommonClaim(
            id: "edit_coinsured",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.hcQuickActionsEditCoinsured,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }

    public static func changeBank() -> CommonClaim {
        CommonClaim(
            id: "change_bank",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.hcQuickActionsChangeBank,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }
}
