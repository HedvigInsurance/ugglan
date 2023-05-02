import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

final class TravelInsuranceStore: StateStore<TravelInsuranceState, TravelInsuranceAction> {

    override func effects(
        _ getState: @escaping () -> TravelInsuranceState,
        _ action: TravelInsuranceAction
    ) -> FiniteSignal<TravelInsuranceAction>? {
        return nil
    }

    override func reduce(_ state: TravelInsuranceState, _ action: TravelInsuranceAction) -> TravelInsuranceState {
        var newState = state
        switch action {
        case .getTravelInsuranceData:
            newState.travelInsuranceModel = TravelInsuranceModel(startDate: Date().localDateString,
                                                                 maxNumberOfConisuredPersons: 1,
                                                                 maxTravelInsuraceDays: 10)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.send(.navigation(.openTravelInsuranceForm))
            }
        default:
            break
        }
        return newState
    }
}
