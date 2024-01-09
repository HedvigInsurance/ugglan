import Apollo
import Contracts
import EditCoInsured
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ImportantMessage: Codable, Equatable {
    let message: String?
    let link: String?
}

public struct UpcomingRenewal: Codable, Equatable {
    let renewalDate: String?
    let draftCertificateUrl: String?

    public init?(
        upcomingRenewal: OctopusGraphQL.AgreementFragment?
    ) {
        guard let upcomingRenewal, upcomingRenewal.creationCause == .renewal else { return nil }
        self.renewalDate = upcomingRenewal.activeFrom
        self.draftCertificateUrl = upcomingRenewal.certificateUrl
    }
}

enum RenewalType {
    case regular
    case coInsured
}

public struct Contract: Codable, Equatable {
    var upcomingRenewal: UpcomingRenewal?
    var displayName: String

    public init(
        contract: OctopusGraphQL.HomeQuery.Data.CurrentMember.ActiveContract
    ) {
        upcomingRenewal = UpcomingRenewal(
            upcomingRenewal: contract.upcomingChangedAgreement?.fragments.agreementFragment
        )
        displayName = contract.exposureDisplayName
    }
}

public struct MemberStateData: Codable, Equatable {
    public let state: MemberContractState
    public let name: String?

    public init(
        state: MemberContractState,
        name: String?
    ) {
        self.state = state
        self.name = name
    }
}

public struct HomeState: StateProtocol {
    public var memberStateData: MemberStateData = .init(state: .loading, name: nil)
    public var futureStatus: FutureStatus = .none
    public var contracts: [Contract] = []
    public var importantMessage: ImportantMessage? = nil
    public var commonClaims: [CommonClaim] = []
    public var allCommonClaims: [CommonClaim] = []
    public var shouldShowTravelInsurance: Bool = false
    public var toolbarOptionTypes: [ToolbarOptionType] = [.chat]
    @Transient(defaultValue: false) var hideImportantMessage = false
    public var upcomingRenewalContracts: [Contract] {
        return contracts.filter { $0.upcomingRenewal != nil }
    }
    public var showChatNotification = false
    public var latestChatTimeStamp = Date()

    public var hasFirstVet: Bool {
        return commonClaims.first(where: { $0.id == "30" || $0.id == "31" || $0.id == "32" }) != nil
    }

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case fetchMemberState
    case fetchImportantMessages
    case setImportantMessage(message: ImportantMessage)
    case connectPayments
    case setMemberContractState(state: MemberStateData, contracts: [Contract])
    case setFutureStatus(status: FutureStatus)
    case fetchUpcomingRenewalContracts
    case openDocument(contractURL: URL)
    case openOtherServices
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case startClaim
    case openFreeTextChat
    case openMovingFlow
    case openTravelInsurance
    case openHelpCenter
    case showNewOffer
    case openCommonClaimDetail(commonClaim: CommonClaim, fromOtherServices: Bool)
    case openCoInsured(contractIds: [InsuredPeopleConfig])
    case openEmergency
    case fetchChatNotifications
    case setChatNotification(hasNew: Bool)
    case setChatNotificationTimeStamp(sentAt: Date)

    case setShowTravelInsurance(show: Bool)
    case dismissOtherServices
    case hideImportantMessage
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

extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    fileprivate var futureStatus: FutureStatus {
        let localDate = Date().localDateString.localDateToDate ?? Date()
        let allActiveInFuture = activeContracts.allSatisfy({ contract in
            return contract.masterInceptionDate.localDateToDate?.daysBetween(start: localDate) ?? 0 > 0
        })

        let externalInsraunceCancellation = pendingContracts.compactMap({ contract in
            contract.externalInsuranceCancellationHandledByHedvig
        })

        if allActiveInFuture && externalInsraunceCancellation.count == 0 {
            return .activeInFuture(inceptionDate: activeContracts.first?.masterInceptionDate ?? "")
        } else if let firstExternal = externalInsraunceCancellation.first {
            return firstExternal ? .pendingSwitchable : .pendingNonswitchable
        }
        return .none
    }
}

public enum HomeLoadingType: LoadingProtocol {
    case fetchCommonClaim
}

public final class HomeStore: LoadingStateStore<HomeState, HomeAction, HomeLoadingType> {
    @Inject var octopus: hOctopus
    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) -> FiniteSignal<HomeAction>? {
        switch action {
        case .fetchImportantMessages:
            return octopus
                .client
                .fetch(query: OctopusGraphQL.ImportantMessagesQuery())
                .map { $0.currentMember.importantMessages.first }
                .map { data in
                    .setImportantMessage(message: .init(message: data?.message, link: data?.link))
                }
                .valueThenEndSignal
        case .fetchMemberState:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag +=
                    self.octopus
                    .client
                    .fetch(query: OctopusGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
                    .onValue { data in
                        let contracts = data.currentMember.activeContracts.map { Contract(contract: $0) }
                        callback(
                            .value(
                                .setMemberContractState(
                                    state: .init(
                                        state: data.currentMember.homeState,
                                        name: data.currentMember.firstName
                                    ),
                                    contracts: contracts
                                )
                            )
                        )
                        callback(.value(.setFutureStatus(status: data.currentMember.futureStatus)))
                    }
                    .onError { [weak self] error in
                        if ApplicationContext.shared.isDemoMode {
                            callback(.value(.setCommonClaims(commonClaims: [])))
                        } else {
                            self?.setError(L10n.General.errorBody, for: .fetchCommonClaim)
                        }
                    }
                return disposeBag
            }
        case .fetchCommonClaims:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.CommonClaimsQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { claimData in
                        let commonClaims = claimData.currentMember.activeContracts
                            .flatMap({ $0.currentAgreement.productVariant.commonClaimDescriptions })
                            .compactMap({ CommonClaim(claim: $0) })
                            .unique()
                        callback(.value(.setCommonClaims(commonClaims: commonClaims)))
                    }
                    .onError { [weak self] error in
                        if ApplicationContext.shared.isDemoMode {
                            callback(.value(.setCommonClaims(commonClaims: [])))
                        } else {
                            self?.setError(L10n.General.errorBody, for: .fetchCommonClaim)
                        }
                    }
                return disposeBag
            }
        case .fetchChatNotifications:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.ChatMessageTimeStampQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { data in
                        if let date = data.chat.messages.first?.sentAt.localDateToIso8601Date {
                            //check if it is auto generated bot message
                            if data.chat.messages.count == 1 && date.addingTimeInterval(2) > Date() {
                                callback(.value(.setChatNotification(hasNew: false)))
                            } else if self.state.latestChatTimeStamp < date {
                                callback(.value(.setChatNotification(hasNew: true)))
                            } else {
                                callback(.value(.setChatNotification(hasNew: false)))
                            }
                        }
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
        case .setImportantMessage(let message):
            if let text = message.message, text != "" {
                newState.importantMessage = message
            } else {
                newState.importantMessage = nil
            }
        case .fetchCommonClaims:
            setLoading(for: .fetchCommonClaim)
        case let .setCommonClaims(commonClaims):
            removeLoading(for: .fetchCommonClaim)
            newState.commonClaims = commonClaims
            setAllCommonClaims(&newState)
        case let .setShowTravelInsurance(show):
            newState.shouldShowTravelInsurance = show
            setAllCommonClaims(&newState)
        case .hideImportantMessage:
            newState.hideImportantMessage = true
        case let .setChatNotification(hasNew):
            newState.showChatNotification = hasNew
            setAllCommonClaims(&newState)
        case let .setChatNotificationTimeStamp(sentAt):
            newState.latestChatTimeStamp = sentAt
            newState.showChatNotification = false
            setAllCommonClaims(&newState)
        default:
            break
        }

        return newState
    }

    private func setAllCommonClaims(_ state: inout HomeState) {
        var allCommonClaims = [CommonClaim]()

        if Dependencies.featureFlags().isHelpCenterEnabled {
            allCommonClaims.append(.helpCenter())
        }

        if Dependencies.featureFlags().isMovingFlowEnabled {
            allCommonClaims.append(.moving())
        }
        if state.shouldShowTravelInsurance {
            allCommonClaims.append(.travelInsurance())
        }
        allCommonClaims.append(contentsOf: state.commonClaims)
        state.allCommonClaims = allCommonClaims

        var types: [ToolbarOptionType] = []
        types.append(.newOffer)

        if state.hasFirstVet {
            types.append(.firstVet)
        }

        if state.showChatNotification {
            types.append(.chatNotification)
        } else {
            types.append(.chat)
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

extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    fileprivate var homeState: MemberContractState {
        if isFuture {
            return .future
        } else if isTerminated {
            return .terminated
        } else {
            return .active
        }
    }

    private var isTerminated: Bool {
        return activeContracts.count == 0 && pendingContracts.count == 0
    }

    private var isFuture: Bool {
        let hasActiveContractsInFuture = activeContracts.allSatisfy { contract in
            return contract.currentAgreement.activeFrom.localDateToDate?.daysBetween(start: Date()) ?? 0 > 0
        }
        return !activeContracts.isEmpty && hasActiveContractsInFuture
    }
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

    public static func chat() -> CommonClaim {
        return CommonClaim(
            id: "chat",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.chatTitle,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
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

    public static func helpCenter() -> CommonClaim {
        CommonClaim(
            id: "help_center",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.hcTitle,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }
}
