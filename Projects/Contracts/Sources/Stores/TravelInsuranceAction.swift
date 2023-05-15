import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

enum TravelInsuranceAction: ActionProtocol, Hashable {
    case getTravelInsuranceData
    case postTravelInsuranceForm
    
    case setEmail(value: String)
    case setDate(value: Date, type: TravelInsuranceDatePickerType)
    case toogleMyselfAsInsured
    case setPolicyCoInsured(PolicyCoinsuredPersonModel)
    case removePolicyCoInsured(PolicyCoinsuredPersonModel)
    
    case postForm
    case navigation(TravelInsuranceNavigationAction)
}

enum TravelInsuranceNavigationAction: ActionProtocol, Hashable {
    case openEmailScreen(email: String)
    case openTravelInsuranceForm
    case openDatePicker(type: TravelInsuranceDatePickerType)
    case openCoinsured(member: PolicyCoinsuredPersonModel?)
    case openTravelInsurance(url: URL, title: String)
    case openSomethingWentWrongScreen
    case dismissAddUpdateCoinsured
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
