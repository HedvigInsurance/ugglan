import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

final class TravelInsuranceStore: StateStore<TravelInsuranceState, TravelInsuranceAction> {
    @Inject var octopus: hOctopus
    
    override func effects(
        _ getState: @escaping () -> TravelInsuranceState,
        _ action: TravelInsuranceAction
    ) -> FiniteSignal<TravelInsuranceAction>? {
        switch action {
        case .getTravelInsuranceData:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(query: OctopusGraphQL.CurrentMemberQuery())
                    .onValue { data in
                        let data = data.currentMember.travelCertificateSpecifications
                        let configs = data.compactMap({TravelInsuranceConfig(model: $0)})
                        callback(.value(.setTravelInsuranceData(config: configs[0])))
                    }
                    .onError { error in
                        callback(.value(.setLoadingState(action: .getTravelInsurance, state: .error(error: L10n.General.errorBody))))
                    }
                return disposeBag
            }
        case .postTravelInsuranceForm:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                guard let config = self.state.travelInsuranceConfig, let travelInsuranceModel = self.state.travelInsuranceModel else {
                    return disposeBag
                }
                let input = OctopusGraphQL.TravelCertificateCreateInput(contractId: config.contractId,
                                                                        startDate: travelInsuranceModel.startDate.localDateString,
                                                                        isMemberIncluded: travelInsuranceModel.isPolicyHolderIncluded,
                                                                        coInsured: travelInsuranceModel.policyCoinsuredPersons.map( {OctopusGraphQL.TravelCertificateCreateCoInsured(fullName: $0.fullName, ssn: $0.personalNumber) }),
                                                                        email: travelInsuranceModel.email)
                let mutation = OctopusGraphQL.CreateTravelCertificateMutation(input: input)
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        if let url = URL(string: data.travelCertificateCreate.signedUrl) {
                            callback(.value(.navigation(.openTravelInsurance(url: url, title: "Travel Certificate"))))
                        } else {
                            callback(.value(.setLoadingState(action: .postTravelInsurance, state: .error(error: L10n.General.errorBody))))
                        }
                    }
                    .onError { error in
                        callback(.value(.setLoadingState(action: .postTravelInsurance, state: .error(error: L10n.General.errorBody))))
                    }
                return disposeBag
            }
        default:
            return nil
        }
    }
    
    override func reduce(_ state: TravelInsuranceState, _ action: TravelInsuranceAction) -> TravelInsuranceState {
        var newState = state
        switch action {
        case .getTravelInsuranceData:
            newState.loadingStates[.getTravelInsurance] = .loading
        case let .setTravelInsuranceData(config):
            newState.loadingStates.removeValue(forKey: .getTravelInsurance)
            newState.travelInsuranceConfig = config
            newState.travelInsuranceModel = TravelInsuranceModel(startDate: config.minStartDate, email: config.email)
            let email = newState.travelInsuranceConfig?.email ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.send(.navigation(.openEmailScreen(email: email)))
            }
        case let .setEmail(value):
            newState.travelInsuranceModel?.email = value
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
        case .postTravelInsuranceForm:
            newState.loadingStates[.postTravelInsurance] = .loading
        case let .navigation(type):
            switch type {
            case .openEmailScreen(let email):
                newState.loadingStates.removeValue(forKey: .getTravelInsurance)
            case .openTravelInsuranceForm:
                break
            case .openDatePicker(let type):
                break
            case .openCoinsured(let member):
                break
            case .openTravelInsurance(let url, let title):
                newState.loadingStates.removeValue(forKey: .postTravelInsurance)
            case .openSomethingWentWrongScreen:
                break
            case .dismissAddUpdateCoinsured:
                break
            case .dismissCreateTravelCertificate:
                break
            case .openFreeTextChat:
                break
            }
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
