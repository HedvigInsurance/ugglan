import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class TerminationContractStore: LoadingStateStore<
ProfileState, ProfileAction, ProfileLoadingAction
>
{
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ProfileState,
        _ action: ProfileAction
    ) -> FiniteSignal<ProfileAction>? {
        return nil
    }

    public override func reduce(
        _ state: ProfileState,
        _ action: ProfileAction
    ) -> ProfileState {
        var newState = state
        return newState
    }
}
