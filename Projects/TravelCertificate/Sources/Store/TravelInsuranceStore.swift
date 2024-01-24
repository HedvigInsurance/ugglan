import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

final class TravelInsuranceStore: LoadingStateStore<
    TravelInsuranceState, TravelInsuranceAction, TravelInsuranceLoadingAction
>
{
    @Inject var octopus: hOctopus
    override func effects(
        _ getState: @escaping () -> TravelInsuranceState,
        _ action: TravelInsuranceAction
    ) -> FiniteSignal<TravelInsuranceAction>? {
        switch action {
        case .postTravelInsuranceForm:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                guard let config = self.state.travelInsuranceConfig,
                    let travelInsuranceModel = self.state.travelInsuranceModel
                else {
                    self.setError(L10n.General.errorBody, for: .postTravelInsurance)
                    return disposeBag
                }
                let input = OctopusGraphQL.TravelCertificateCreateInput(
                    contractId: config.contractId,
                    startDate: travelInsuranceModel.startDate.localDateString,
                    isMemberIncluded: travelInsuranceModel.isPolicyHolderIncluded,
                    coInsured: travelInsuranceModel.policyCoinsuredPersons.map({
                        OctopusGraphQL.TravelCertificateCreateCoInsured(fullName: $0.fullName, ssn: $0.personalNumber)
                    }),
                    email: travelInsuranceModel.email
                )
                let mutation = OctopusGraphQL.CreateTravelCertificateMutation(input: input)
                let graphQlMutation = self.octopus.client.perform(mutation: mutation)
                let minimumTime = Signal(after: 1.5).future
                disposeBag += combineLatest(graphQlMutation.resultSignal, minimumTime.resultSignal)
                    .onValue { [weak self] mutation, minimumTime in
                        if let data = mutation.value {
                            if let url = URL(string: data.travelCertificateCreate.signedUrl) {
                                callback(
                                    .value(
                                        .setDownloadUrl(urL: url)
                                    )
                                )
                            } else {
                                self?.setError(L10n.General.errorBody, for: .postTravelInsurance)
                            }
                        } else if let _ = mutation.error {
                            self?.setError(L10n.General.errorBody, for: .postTravelInsurance)
                        }
                    }
                return disposeBag
            }
        case .getTravelCertificateSpecification:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.TravelCertificateQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { data in
                        let email = data.currentMember.email
                        let specification = TravelInsuranceSpecification(
                            data.currentMember,
                            email: email
                        )
                        callback(.value(.setTravelInsurancesData(specification: specification)))
                        callback(.value(.travelCertificateSpecificationSet))
                    }
                    .onError { error in
                        // TODO
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
        case .getTravelCertificateSpecification:
            break
        case .travelCertificateSpecificationSet:
            break
        case let .setTravelInsurancesData(config):
            removeLoading(for: .getTravelInsurance)
            if let contractSpecification = config.travelCertificateSpecifications.first {
                newState.travelInsuranceConfig = contractSpecification
                newState.travelInsuranceModel = TravelInsuranceModel(
                    startDate: contractSpecification.minStartDate,
                    minStartDate: contractSpecification.minStartDate,
                    maxStartDate: contractSpecification.maxStartDate,
                    email: config.email ?? "",
                    fullName: config.fullName
                )
                newState.travelInsuranceConfig = config.travelCertificateSpecifications.first
                newState.travelInsuranceConfigs = config

            }
        case let .setTravelInsuranceData(config):
            newState.travelInsuranceModel = TravelInsuranceModel(
                startDate: config.minStartDate,
                minStartDate: config.minStartDate,
                maxStartDate: config.maxStartDate,
                email: newState.travelInsuranceConfigs?.email ?? "",
                fullName: newState.travelInsuranceConfigs?.fullName ?? ""
            )
            newState.travelInsuranceConfig = config
        case let .setEmail(value):
            newState.travelInsuranceModel?.email = value
            send(.navigation(.openWhoIsTravelingScreen))
        case .toogleMyselfAsInsured:
            newState.travelInsuranceModel?.isPolicyHolderIncluded.toggle()
        case let .setPolicyCoInsured(data):
            let indexOfUser = newState.travelInsuranceModel?.policyCoinsuredPersons
                .firstIndex(where: { $0.personalNumber == data.personalNumber })
            if indexOfUser == nil {
                newState.travelInsuranceModel?.policyCoinsuredPersons.append(data)
            }
        case let .updatePolicyCoInsured(old, new):
            let indexOfUser = newState.travelInsuranceModel?.policyCoinsuredPersons
                .firstIndex(where: { $0.personalNumber == old.personalNumber })
            if let indexOfUser {
                newState.travelInsuranceModel?.policyCoinsuredPersons[indexOfUser] = new
            }
        case let .removePolicyCoInsured(data):
            newState.travelInsuranceModel?.policyCoinsuredPersons
                .removeAll(where: { model in
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
            setLoading(for: .postTravelInsurance)
        case let .setDownloadUrl(url):
            newState.downloadURL = url
            removeLoading(for: .postTravelInsurance)
        case let .navigation(type):
            switch type {
            case .openStartDateScreen:
                break
            case .openWhoIsTravelingScreen:
                break
            case .openCoinsured:
                break
            case .dismissAddUpdateCoinsured:
                break
            case .dismissCreateTravelCertificate:
                break
            case .openFreeTextChat:
                break
            case .openProcessingScreen:
                break
            case .goBack:
                break
            }
        }
        return newState
    }
}
