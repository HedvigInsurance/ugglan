import Flow
import Presentation
import Apollo
import hCore
import hGraphQL

public struct HomeState: StateProtocol {
    var memberContractState: MemberContractState = .loading
    
    public init() {}
}

public enum HomeAction: ActionProtocol {
    case openFreeTextChat
    case fetchMemberState
    case openMovingFlow
    case openClaims
    case connectPayments
    case setMemberContractState(MemberContractState)
    
    #if compiler(<5.5)
        public func encode(to encoder: Encoder) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }

        public init(
            from decoder: Decoder
        ) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }
    #endif
}


public final class HomeStore: StateStore<HomeState, HomeAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    
    public override func effects(_ getState: () -> HomeState, _ action: HomeAction) -> FiniteSignal<HomeAction>? {
        switch action {
        case .openFreeTextChat:
            return nil
        case .fetchMemberState:
            return client
                .fetch(query: GraphQL.HomeQuery())
                .compactMap { $0.homeState }
                .map { state in
                    .setMemberContractState(state)
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
            newState.memberContractState = memberState
        case .openFreeTextChat:
            break
        case .fetchMemberState:
            break
        case .openClaims:
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
        if isTerminated {
            return .terminated
        } else if isFuture {
            return .future
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
