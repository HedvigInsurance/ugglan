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
    var claims: [Claim]? = nil
    var claimsNeedsUpdating = false

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case openFreeTextChat
    case fetchMemberState
    case openMovingFlow
    case openClaims
    case connectPayments
    case setMemberContractState(state: MemberStateData)
    case fetchClaims
    case setClaims(claims: [Claim])
    case setClaimsNeedsUpdating
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
        case .fetchClaims:
            return
                client
                .fetch(
                    query: GraphQL.ClaimStatusCardsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .compactMap {
                    ClaimStatusCards(cardData: $0)
                }
                .map { claimData in
                    return .setClaims(claims: claimData.claims)
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
        case .openClaims:
            break
        case .connectPayments:
            break
        case .openMovingFlow:
            break
        case .fetchClaims:
            break
        case let .setClaims(claims):
            newState.claims = claims
        case .setClaimsNeedsUpdating:
            newState.claimsNeedsUpdating = true
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
