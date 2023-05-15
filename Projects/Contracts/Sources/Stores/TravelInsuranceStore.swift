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
            newState.travelInsuranceConfig = TravelInsuranceConfig(contractId: "contractId",
                                                                   minStartDate: Date(),
                                                                   maxStartDate: Date().addingTimeInterval(60 * 60 * 24 * 20),
                                                                   numberOfCoInsured: 1,
                                                                   maxDuration: 45,
                                                                   email: "email@email.com")
            newState.travelInsuranceModel = TravelInsuranceModel(startDate: Date())
            let email = newState.travelInsuranceConfig?.email ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.send(.navigation(.openEmailScreen(email: email)))
            }
        case let .setEmail(value):
            send(.navigation(.openTravelInsuranceForm))
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
            case .endDate:
                break
            }
        case .postForm:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.send(.navigation(.openTravelInsurance(url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!, title: "Travel Certificate")))
            }
        default:
            break
        }
        return newState
    }
}
