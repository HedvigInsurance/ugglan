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
            let maxDate = Date().addingTimeInterval(60 * 60 * 24 * 100)
            newState.travelInsuranceConfig = TravelInsuranceConfig(minimumDate: Date(),
                                                                   maximumDate: maxDate,
                                                                   maxNumberOfConisuredPersons: 2,
                                                                   maxTravelInsuraceDays: 45)
            newState.travelInsuranceModel = TravelInsuranceModel(startDate: Date())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.send(.navigation(.openTravelInsuranceForm))
            }
        case .toogleMyselfAsInsured:
            newState.travelInsuranceModel?.isPolicyHolderIncluded.toggle()
        case let .setPolicyCoInsured(data):
            let indexOfUser = newState.travelInsuranceModel?.policyCoinsuredPersons.firstIndex(where: {$0.personalNumber == data.personalNumber})
            if let indexOfUser {
                newState.travelInsuranceModel?.policyCoinsuredPersons[indexOfUser] = data
            } else {
                newState.travelInsuranceModel?.policyCoinsuredPersons.append(data)
            }
        case let .removePolicyCoInsured(data):
            newState.travelInsuranceModel?.policyCoinsuredPersons.removeAll(where: { model in
                model.personalNumber == data.personalNumber
            })
        case let .setDate(date, type):
            switch type {
            case .startDate:
                newState.travelInsuranceModel?.startDate = date
                if let endDate = newState.travelInsuranceModel?.endDate,
                endDate < date{
                    newState.travelInsuranceModel?.endDate = nil
                }
            case .endDate:
                newState.travelInsuranceModel?.endDate = date
                if let startDate = newState.travelInsuranceModel?.startDate,
                   startDate > date {
                    newState.travelInsuranceModel?.startDate = date
                }
            }
        default:
            break
        }
        return newState
    }
}
