import Apollo
import Flow
import Presentation
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil

    public init() {}

    public var hasActiveClaims: Bool {
        if let claims = claims {
            return
                !claims.filter {
                    $0.claimDetailData.status == .beingHandled || $0.claimDetailData.status == .reopened
                        || $0.claimDetailData.status == .submitted
                }
                .isEmpty
        }
        return false
    }
}

public enum ClaimsAction: ActionProtocol {
    case openFreeTextChat
    case submitNewClaim
    case fetchClaims
    case setClaims(claims: [Claim])
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
    case submitOdysseyClaim
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
        case .fetchCommonClaims:
            return
                client.fetch(
                    query: GraphQL.CommonClaimsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                )
                .map { data in
                    let commonClaims = data.commonClaims.map {
                        CommonClaim(claim: $0)
                    }
                    return .setCommonClaims(commonClaims: commonClaims)
                }
                .valueThenEndSignal
        default:
            return nil
        }
    }

    public override func reduce(_ state: ClaimsState, _ action: ClaimsAction) -> ClaimsState {
        var newState = state

        switch action {
        case .openFreeTextChat:
            break
        case .fetchClaims:
            break
        case .fetchCommonClaims:
            break
        case .openHowClaimsWork:
            break
        case .openCommonClaimDetail:
            break
        case let .setClaims(claims):
            newState.claims = claims
        case let .setCommonClaims(commonClaims):
            newState.commonClaims = commonClaims
        case .openClaimDetails:
            break
        case .submitNewClaim:
            break
        case .submitOdysseyClaim:
            break
        }

        return newState
    }
}
