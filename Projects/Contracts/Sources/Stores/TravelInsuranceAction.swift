import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

enum TravelInsuranceAction: ActionProtocol, Hashable {
    case getTravelInsuranceData
    case setTravelInsurancesData(specification: TravelInsuranceSpecification)
    case setTravelInsuranceData(specification: TravelInsuranceContractSpecification)
    case postTravelInsuranceForm
    
    case setEmail(value: String)
    case setDate(value: Date, type: TravelInsuranceDatePickerType)
    case toogleMyselfAsInsured
    case setPolicyCoInsured(PolicyCoinsuredPersonModel)
    case removePolicyCoInsured(PolicyCoinsuredPersonModel)
    
    case navigation(TravelInsuranceNavigationAction)
    case setLoadingState(action: TravelInsuranceLoadingAction, state: LoadingState<String>?)
}

enum TravelInsuranceNavigationAction: ActionProtocol, Hashable {
    case openEmailScreen
    case openTravelInsuranceForm
    case openDatePicker(type: TravelInsuranceDatePickerType)
    case openCoinsured(member: PolicyCoinsuredPersonModel?)
    case openTravelInsurance(url: URL, title: String)
    case openSomethingWentWrongScreen
    case dismissAddUpdateCoinsured
    case dismissCreateTravelCertificate
    case openFreeTextChat
}

enum TravelInsuranceLoadingAction: ActionProtocol, Hashable {
    case getTravelInsurance
    case postTravelInsurance
}

enum TravelInsuranceDatePickerType: ActionProtocol, Hashable {
    case startDate
    case endDate
    
    var title: String {
        switch self {
        case .startDate:
            return "From"
        case .endDate:
            return "To"
        }
    }
}
