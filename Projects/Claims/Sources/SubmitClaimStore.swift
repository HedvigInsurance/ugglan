import Apollo
import Combine
import PresentableStore
import SwiftUI
import hCore

public final class SubmitClaimStore: LoadingStateStore<SubmitClaimsState, SubmitClaimsAction, ClaimsLoadingType> {
    public override func effects(
        _ getState: @escaping () -> SubmitClaimsState,
        _ action: SubmitClaimsAction
    ) async {
        switch action {
        default:
            break
        }
    }

    public override func reduce(_ state: SubmitClaimsState, _ action: SubmitClaimsAction) -> SubmitClaimsState {
        var newState = state
        switch action {
        default:
            break
        }
        return newState
    }
}
