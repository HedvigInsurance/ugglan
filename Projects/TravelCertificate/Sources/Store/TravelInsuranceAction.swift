import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

enum TravelInsuranceAction: ActionProtocol, Hashable {
    case setTravelInsurancesData(specification: TravelInsuranceSpecification)
    case setTravelInsuranceData(specification: TravelInsuranceContractSpecification)
    case postTravelInsuranceForm
    case getTravelInsruancesList
    case setTravelInsruancesList(list: [TravelCertificateListModel])

    case setEmail(value: String)
    case setDate(value: Date, type: TravelInsuranceDatePickerType)
    case toogleMyselfAsInsured
    case setPolicyCoInsured(PolicyCoinsuredPersonModel)
    case updatePolicyCoInsured(PolicyCoinsuredPersonModel, with: PolicyCoinsuredPersonModel)
    case removePolicyCoInsured(PolicyCoinsuredPersonModel)
    case setDownloadUrl(urL: URL)

    case navigation(TravelInsuranceNavigationAction)
    case getTravelCertificateSpecification
    case travelCertificateSpecificationSet
}

enum TravelInsuranceNavigationAction: ActionProtocol, Hashable {
    case openStartDateScreen
    case openWhoIsTravelingScreen
    case openCoinsured(member: PolicyCoinsuredPersonModel?)
    case dismissAddUpdateCoinsured
    case dismissCreateTravelCertificate
    case openFreeTextChat
    case openProcessingScreen
    case goBack
}

enum TravelInsuranceLoadingAction: LoadingProtocol {
    case getTravelInsuranceSpecifications
    case getTravelInsurancesList
    case postTravelInsurance
    case downloadCertificate
}

enum TravelInsuranceDatePickerType: ActionProtocol, Hashable {
    case startDate
    case endDate
}
