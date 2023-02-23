import Apollo
import Flow
import Presentation
import hCore
import hGraphQL

public struct MemberStateData: Codable, Equatable {
    let state: MemberContractState
    let name: String?
}

public struct HomeState: StateProtocol {
    var memberStateData: MemberStateData = .init(state: .loading, name: nil)

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case openFreeTextChat
    case fetchMemberState
    case openMovingFlow
    case connectPayments
    case setMemberContractState(state: MemberStateData)
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
        default:
            return nil
        }
    }

    public override func reduce(_ state: HomeState, _ action: HomeAction) -> HomeState {
        var newState = state

        switch action {
        case .setMemberContractState(let memberState):
            newState.memberStateData = memberState
        case .openFreeTextChat:
            break
        case .fetchMemberState:
            break
        case .connectPayments:
            break
        case .openMovingFlow:
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
