import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var giraffe: hGiraffe

    public override func effects(
        _ getState: @escaping () -> ClaimsState,
        _ action: ClaimsAction
    ) -> FiniteSignal<ClaimsAction>? {
        switch action {
        case .openFreeTextChat:
            return nil
        case .fetchClaims:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetch(
                        query: GiraffeGraphQL.ClaimStatusCardsQuery(
                            locale: Localization.Locale.currentLocale.asGraphQLLocale()
                        ),
                        cachePolicy: .fetchIgnoringCacheData
                    )
                    .onValue { claimData in
                        let claimData = ClaimData(cardData: claimData)  // TODO: need to sort out empty values
                        callback(.value(ClaimsAction.setClaims(claims: claimData.claims)))
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(.value(.setLoadingState(action: action, state: .error(error: L10n.General.errorBody))))
                    }
                return disposeBag
            }
        //            return giraffe
        //                .client
        //                .fetch(
        //                    query: GiraffeGraphQL.ClaimStatusCardsQuery(
        //                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
        //                    ),
        //                    cachePolicy: .fetchIgnoringCacheData
        //                )
        //                .compactMap {
        //                    ClaimData(cardData: $0)
        //                }
        //                .map { claimData in
        //                    return .setClaims(claims: claimData.claims)
        //                }
        //                .valueThenEndSignal
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
                        callback(.value(ClaimsAction.setCommonClaims(commonClaims: commonClaims)))
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(.value(.setLoadingState(action: action, state: .error(error: L10n.General.errorBody))))
                    }
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: ClaimsState, _ action: ClaimsAction) -> ClaimsState {
        var newState = state
        switch action {
        case let .setClaims(claims):
            newState.claims = claims
        case let .setCommonClaims(commonClaims):
            newState.commonClaims = commonClaims
        case let .setLoadingState(action, state):
            if let state {
                newState.loadingStates[action] = state
            } else {
                newState.loadingStates.removeValue(forKey: action)
            }
        default:
            break
        }
        return newState
    }
}
