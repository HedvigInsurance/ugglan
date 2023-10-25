import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var octopus: hOctopus

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
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.ClaimsQuery(),
                        cachePolicy: .fetchIgnoringCacheData
                    )
                    .onValue { data in
                        let claimData = data.currentMember.claims.map { ClaimModel(claim: $0) }
                        callback(.value(ClaimsAction.setClaims(claims: claimData)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(action: action, state: .error(error: L10n.General.errorBody))
                            )
                        )
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
        case .fetchClaims:
            newState.loadingStates[action] = .loading
        case let .setClaims(claims):
            newState.loadingStates.removeValue(forKey: .fetchClaims)
            newState.claims = claims
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
