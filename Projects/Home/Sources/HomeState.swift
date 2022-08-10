import Apollo
import Flow
import Presentation
import hCore
import hGraphQL

//public typealias InsuranceProvider = GraphQL.HomeInsuranceProvidersQuery.Data.InsuranceProvider

public struct MemberStateData: Codable, Equatable {
    let state: MemberContractState
    let name: String?
}

public struct HomeState: StateProtocol {
    var memberStateData: MemberStateData = .init(state: .loading, name: nil)
    var futureStatus: FutureStatus = .none

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case openFreeTextChat
    case fetchMemberState
    case openMovingFlow
    case openClaim
    case connectPayments
    case setMemberContractState(state: MemberStateData)
    case fetchFutureStatus
    case setFutureStatus(status: FutureStatus)
}

public enum FutureStatus: Codable, Equatable {
    case activeInFuture(inceptionDate: String)
    case pendingSwitchable
    case pendingNonswitchable
    case none
}

public final class HomeStore: StateStore<HomeState, HomeAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) -> FiniteSignal<HomeAction>? {
        switch action {
        case .openFreeTextChat:
            return nil
        case .fetchMemberState:
            return
                client
                .fetch(query: GraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
                .map { data in
                    .setMemberContractState(state: .init(state: data.homeState, name: data.member.firstName))
                }
                .valueThenEndSignal
        case .fetchFutureStatus:
            return
                client
                .fetch(
                    query: GraphQL.HomeInsuranceProvidersQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .join(with: client.fetch(query: GraphQL.HomeQuery()))
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
        default:
            return nil
        }
    }

    public override func reduce(_ state: HomeState, _ action: HomeAction) -> HomeState {
        var newState = state

        switch action {
        case .setMemberContractState(let memberState):
            newState.memberStateData = memberState
        case .setFutureStatus(let status):
            newState.futureStatus = status
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

extension GraphQL.HomeQuery.Data {
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
