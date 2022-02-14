import Apollo
import Flow
import Presentation
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var claims: [Claim]? = nil

    public init() {}
}

public enum ClaimsAction: ActionProtocol {
    case openFreeTextChat
    case submitClaims
    case fetchClaims
    case setClaims(claims: [Claim])
    case openHowClaimsWork
    case startPollingClaims
    case stopPollingClaims
    case openClaimDetails(claim: Claim)
}

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    public override func effects(
        _ getState: @escaping () -> ClaimsState,
        _ action: ClaimsAction
    ) -> FiniteSignal<ClaimsAction>? {
        switch action {
        case .openFreeTextChat:
            return nil
        case .fetchClaims:
            return
                client
                .fetch(
                    query: GraphQL.ClaimStatusCardsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .compactMap {
                    ClaimData(cardData: $0)
                }
                .map { claimData in
                    return .setClaims(claims: claimData.claims)
                }
                .valueThenEndSignal
        case .startPollingClaims:
            return Signal(every: 2).map { .fetchClaims }
        case .stopPollingClaims:
            cancelEffect(.startPollingClaims)
        default:
            return nil
        }

        return nil
    }

    public override func reduce(_ state: ClaimsState, _ action: ClaimsAction) -> ClaimsState {
        var newState = state

        switch action {
        case .openFreeTextChat:
            break
        case .fetchClaims:
            break
        case .openHowClaimsWork:
            break
        case let .setClaims(claims):
            newState.claims = claims
        case .startPollingClaims:
            break
        case .stopPollingClaims:
            break
        case .openClaimDetails:
            break
        case .submitClaims:
            break
        }

        return newState
    }
}
