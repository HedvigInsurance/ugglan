import Apollo
import Contracts
import Foundation
import Presentation
import hCore
import hGraphQL

public final class TravelInsuranceStore: StateStore<
    TravelInsuranceState, TravelInsuranceAction
>
{

    var startDateViewModel: StartDateViewModel?
    var whoIsTravelingViewModel: WhoIsTravelingViewModel?
    public override func effects(
        _ getState: @escaping () -> TravelInsuranceState,
        _ action: TravelInsuranceAction
    ) async {
    }

    public override func reduce(_ state: TravelInsuranceState, _ action: TravelInsuranceAction) -> TravelInsuranceState
    {
        var newState = state
        return newState
    }
}
