import Apollo
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum TravelInsuranceAction: ActionProtocol, Hashable {
    case navigation(TravelInsuranceNavigationAction)
    case goToEditCoInsured
    case dismissTravelInsuranceFlow
}

public enum TravelInsuranceNavigationAction: ActionProtocol, Hashable {
    //    case openStartDateScreen(spacification: TravelInsuranceContractSpecification)
    //    case openWhoIsTravelingScreen
    case dismissCreateTravelCertificate
    case openFreeTextChat
    case openProcessingScreen
    case goBack
    case openDetails(for: TravelCertificateModel)
}
