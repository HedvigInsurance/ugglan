import Apollo
import Flow
import Foundation
import Presentation
import hCore
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

public struct HomeState: StateProtocol {
    public var memberStateData: MemberStateData = .init(state: .loading, name: nil)
    public var futureStatus: FutureStatus = .none
    public var contracts: [Contract] = []
    public var importantMessage: ImportantMessage? = nil

    public var upcomingRenewalContracts: [Contract] {
        return contracts.filter { $0.upcomingRenewal != nil }
    }

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case openFreeTextChat
    case fetchMemberState
    case fetchImportantMessages
    case setImportantMessage(message: ImportantMessage)
    case openMovingFlow
    case openTravelInsurance
    case connectPayments
    case setMemberContractState(state: MemberStateData, contracts: [Contract])
    case fetchFutureStatus
    case setFutureStatus(status: FutureStatus)
    case fetchUpcomingRenewalContracts
    case openDocument(contractURL: URL)
}

public enum FutureStatus: Codable, Equatable {
    case activeInFuture(inceptionDate: String)
    case pendingSwitchable
    case pendingNonswitchable
    case none
}

public final class HomeStore: StateStore<HomeState, HomeAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus
    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) -> FiniteSignal<HomeAction>? {
        switch action {
        case .openFreeTextChat:
            return nil
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
//        case .getTravelInsuranceData:
//            return FiniteSignal { callback in
//                let disposeBag = DisposeBag()
//                disposeBag += self.octopus.client
//                    .fetch(query: OctopusGraphQL.TravelCertificateQuery())
//                    .onValue { data in
//                        let email = data.currentMember.email
//                        
//                        let specification = TravelInsuranceSpecification(data.currentMember.travelCertificateSpecifications, email: email)
////                        callback(.value(.setTravelInsurancesData(specification: specification)))
//                    }
//                    .onError { error in
////                        callback(.value(.setLoadingState(action: .getTravelInsurance, state: .error(error: L10n.General.errorBody))))
//                    }
//                return disposeBag
//            }
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
        default:
            break
        }

        return newState
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
                || contract.status.asTerminatedTodayStatus != nil
        })
    }

    private var isFuture: Bool {
        contracts.allSatisfy { (contract) -> Bool in
            contract.status.asActiveInFutureStatus != nil || contract.status.asPendingStatus != nil
        }
    }
}
