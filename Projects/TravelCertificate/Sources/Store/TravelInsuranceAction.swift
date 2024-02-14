import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum TravelInsuranceAction: ActionProtocol, Hashable {
    case setTravelInsurancesData(specification: TravelInsuranceSpecification)
    case setTravelInsuranceData(specification: TravelInsuranceContractSpecification)
    case postTravelInsuranceForm
    case getTravelInsruancesList
    case setTravelInsruancesList(list: [TravelCertificateModel])

    case setEmail(value: String)
    case setDate(value: Date, type: TravelInsuranceDatePickerType)
    case toogleMyselfAsInsured
    case setPolicyCoInsured(PolicyCoinsuredPersonModel)
    case setDownloadUrl(urL: URL)

    case navigation(TravelInsuranceNavigationAction)
    case getTravelCertificateSpecification
    case travelCertificateSpecificationSet
    case goToEditCoInsured
    case dismissTravelInsuranceFlow
}

public enum TravelInsuranceNavigationAction: ActionProtocol, Hashable {
    case openCreateNew
    case openStartDateScreen
    case openWhoIsTravelingScreen
    case openCoinsured(member: PolicyCoinsuredPersonModel?)
    case dismissAddUpdateCoinsured
    case dismissCreateTravelCertificate
    case openFreeTextChat
    case openProcessingScreen
    case goBack
    case openDetails(for: TravelCertificateModel)
}

public enum TravelInsuranceLoadingAction: LoadingProtocol {
    case getTravelInsuranceSpecifications
    case getTravelInsurancesList
    case postTravelInsurance
    case downloadCertificate
}

public enum TravelInsuranceDatePickerType: ActionProtocol, Hashable {
    case startDate
    case endDate
}
