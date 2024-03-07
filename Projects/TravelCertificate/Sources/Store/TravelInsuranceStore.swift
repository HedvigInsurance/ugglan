import Apollo
import Contracts
import Foundation
import Presentation
import hCore
import hGraphQL

public final class TravelInsuranceStore: LoadingStateStore<
    TravelInsuranceState, TravelInsuranceAction, TravelInsuranceLoadingAction
>
{
    @Inject var travelInsuranceClient: TravelInsuranceClient
    public override func effects(
        _ getState: @escaping () -> TravelInsuranceState,
        _ action: TravelInsuranceAction
    ) async throws {
        switch action {
        case .postTravelInsuranceForm:
            guard let config = self.state.travelInsuranceConfig,
                let travelInsuranceModel = self.state.travelInsuranceModel
            else {
                self.setError(L10n.General.errorBody, for: .postTravelInsurance)
                return
            }

            let dto = TravenInsuranceFormDTO(
                contractId: config.contractId,
                startDate: travelInsuranceModel.startDate.localDateString,
                isMemberIncluded: travelInsuranceModel.isPolicyHolderIncluded,
                coInsured: travelInsuranceModel.policyCoinsuredPersons.compactMap(
                    { .init(fullName: $0.fullName, personalNumber: $0.personalNumber, birthDate: $0.birthDate) }
                ),
                email: travelInsuranceModel.email
            )
            do {
                let url = try await self.travelInsuranceClient.submitForm(dto: dto)
                AskForRating().askForReview()
                send(.setDownloadUrl(urL: url))
            } catch _ {
                self.setError(L10n.General.errorBody, for: .postTravelInsurance)
            }
        case .getTravelCertificateSpecification:
            do {
                let specification = try await self.travelInsuranceClient.getSpecifications()
                send(.setTravelInsurancesData(specification: specification))
                send(.travelCertificateSpecificationSet)
            } catch _ {
                self.setError(L10n.General.errorBody, for: .getTravelInsuranceSpecifications)
            }
        case .getTravelInsruancesList:
            do {
                let list = try await self.travelInsuranceClient.getList()
                send(.setTravelInsruancesList(list: list))
            } catch _ {
                self.setError(L10n.General.errorBody, for: .getTravelInsurancesList)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: TravelInsuranceState, _ action: TravelInsuranceAction) -> TravelInsuranceState
    {
        var newState = state
        switch action {
        case .getTravelCertificateSpecification:
            self.setLoading(for: .getTravelInsuranceSpecifications)
        case .travelCertificateSpecificationSet:
            break
        case let .setTravelInsurancesData(config):
            removeLoading(for: .getTravelInsuranceSpecifications)
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
        case let .setPolicyCoInsured(data):
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            let contract = contractStore.state.contractForId(state.travelInsuranceConfig?.contractId ?? "")
            newState.travelInsuranceModel?.isPolicyHolderIncluded = false
            newState.travelInsuranceModel?.policyCoinsuredPersons = []
            data.forEach { coInsured in
                if coInsured.fullName == contract?.fullName && coInsured.personalNumber == contract?.ssn {
                    newState.travelInsuranceModel?.isPolicyHolderIncluded = true
                } else {
                    newState.travelInsuranceModel?.policyCoinsuredPersons.append(contentsOf: data)
                }
            }
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
        case .getTravelInsruancesList:
            setLoading(for: .getTravelInsurancesList)
        case let .setTravelInsruancesList(list):
            newState.travelInsuranceList = list
            removeLoading(for: .getTravelInsurancesList)
        case let .navigation(type):
            switch type {
            case .openStartDateScreen:
                break
            case .openWhoIsTravelingScreen:
                break
            case .dismissCreateTravelCertificate:
                break
            case .openFreeTextChat:
                break
            case .openProcessingScreen:
                break
            case .goBack:
                break
            case .openDetails:
                break
            case .openCreateNew:
                break
            }
        case .goToEditCoInsured:
            break
        case .dismissTravelInsuranceFlow:
            break
        }
        return newState
    }
}
