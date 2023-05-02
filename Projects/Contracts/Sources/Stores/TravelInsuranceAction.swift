import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

enum TravelInsuranceAction: ActionProtocol, Hashable {
    case getTravelInsuranceData
    case postTravelInsuranceForm
    case navigation(TravelInsuranceNavigationAction)
}

enum TravelInsuranceNavigationAction: ActionProtocol, Hashable {
    case openTravelInsuranceForm
    case openDatePicker
    case openCoinsured(member: PolicyCoinsuredPersonModel?)
}
