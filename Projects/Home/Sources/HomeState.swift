import Apollo
import Flow
import Foundation
import Presentation
import hAnalytics
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

    public init(
        upcomingRenewal: GiraffeGraphQL.HomeQuery.Data.Contract.UpcomingRenewal?
    ) {
        self.renewalDate = upcomingRenewal?.renewalDate
        self.draftCertificateUrl = upcomingRenewal?.draftCertificateUrl
    }
}

public struct Contract: Codable, Equatable {
    var upcomingRenewal: UpcomingRenewal?
    var displayName: String

    public init(
        contract: GiraffeGraphQL.HomeQuery.Data.Contract
    ) {
        if contract.upcomingRenewal != nil {
            upcomingRenewal = UpcomingRenewal(upcomingRenewal: contract.upcomingRenewal)
        }
        displayName = contract.displayName
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

public struct OtherServiceData: Codable, Equatable {
    let type: OtherServicesType
}

public enum OtherServicesType: String, Codable, Equatable {
    case chat
    case changeAddress
    case travelCertificate
    case contactFirstVet
    case sickAbroad

    var title: String {
        switch self {
        case .chat: return L10n.chatTitle
        case .changeAddress: return L10n.InsuranceDetails.changeAddressButton
        case .travelCertificate: return L10n.TravelCertificate.cardTitle
        case .contactFirstVet: return "Contact FirstVet"
        case .sickAbroad: return "Sick abroad"
        }
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
    case fetchFutureStatus
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
    case showNewOffer
    case openCommonClaimDetail(commonClaim: CommonClaim, fromOtherServices: Bool)

    case setShowTravelInsurance(show: Bool)
    case dismissOtherServices
    case hideImportantMessage

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
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus
    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) -> FiniteSignal<HomeAction>? {
        switch action {
        case .fetchImportantMessages:
            return
                giraffe
                .client
                .fetch(query: GiraffeGraphQL.ImportantMessagesQuery(langCode: Localization.Locale.currentLocale.code))
                .compactMap { $0.importantMessages.first }
                .compactMap { $0 }
                .map { data in
                    .setImportantMessage(message: .init(message: data.message, link: data.link))
                }
                .valueThenEndSignal
        case .fetchMemberState:
            return
                giraffe
                .client
                .fetch(query: GiraffeGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
                .map { data in
                    .setMemberContractState(
                        state: .init(state: data.homeState, name: data.member.firstName),
                        contracts: data.contracts.map { Contract(contract: $0) }
                    )
                }
                .valueThenEndSignal
        case .fetchFutureStatus:
            return
                giraffe
                .client
                .fetch(
                    query: GiraffeGraphQL.HomeInsuranceProvidersQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .join(with: giraffe.client.fetch(query: GiraffeGraphQL.HomeQuery()))
                .map { insuranceProviderData, homeData in
                    if let contract = homeData.contracts.first(where: {
                        $0.status.asActiveInFutureStatus != nil || $0.status.asPendingStatus != nil
                    }) {
                        if let activeInFutureStatus = contract.status.asActiveInFutureStatus {
                            return .setFutureStatus(
                                status: .activeInFuture(inceptionDate: activeInFutureStatus.futureInception ?? "")
                            )
                        } else if let switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider,
                            let insuranceProvider = insuranceProviderData.insuranceProviders.first(where: {
                                provider -> Bool in provider.id == switchedFromInsuranceProvider
                            }), insuranceProvider.switchable
                        {
                            return .setFutureStatus(status: .pendingSwitchable)
                        } else {
                            return .setFutureStatus(status: .pendingNonswitchable)
                        }
                    } else {
                        return .setFutureStatus(status: .none)
                    }
                }
                .valueThenEndSignal
        case .fetchCommonClaims:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetch(
                        query: GiraffeGraphQL.CommonClaimsQuery(
                            locale: Localization.Locale.currentLocale.asGraphQLLocale()
                        )
                    )
                    .onValue { claimData in
                        let commonClaims = claimData.commonClaims.map {
                            CommonClaim(claim: $0)
                        }
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
        default:
            break
        }

        return newState
    }

    private func setAllCommonClaims(_ state: inout HomeState) {
        var allCommonClaims = [CommonClaim]()
        allCommonClaims.append(.chat)
        if hAnalyticsExperiment.movingFlow {
            allCommonClaims.append(.moving)
        }
        if state.shouldShowTravelInsurance {
            allCommonClaims.append(.travelInsurance)
        }
        allCommonClaims.append(contentsOf: state.commonClaims)
        state.allCommonClaims = allCommonClaims
        var types: [ToolbarOptionType] = []
        types.append(.newOffer)
        if state.hasFirstVet {
            types.append(.firstVet)
        }
        types.append(.chat)

        state.toolbarOptionTypes = types

    }
}

public enum MemberContractState: String, Codable, Equatable {
    case terminated
    case future
    case active
    case loading
}

extension GiraffeGraphQL.HomeQuery.Data {
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
        contracts.allSatisfy({ (contract) -> Bool in
            contract.status.asActiveInFutureStatus != nil || contract.status.asTerminatedStatus != nil
        })
    }

    private var isFuture: Bool {
        contracts.allSatisfy { (contract) -> Bool in
            contract.status.asActiveInFutureStatus != nil || contract.status.asPendingStatus != nil
        }
    }
}

extension CommonClaim {
    public static let travelInsurance: CommonClaim = {
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
    }()

    public static let chat: CommonClaim = {
        CommonClaim(
            id: "chat",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.chatTitle,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }()

    public static let moving: CommonClaim = {
        CommonClaim(
            id: "moving_flow",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.InsuranceDetails.changeAddressButton,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }()

}
