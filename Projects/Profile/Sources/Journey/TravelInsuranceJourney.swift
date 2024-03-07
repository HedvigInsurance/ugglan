import Foundation
import Presentation
import SwiftUI
import TravelCertificate

public class TravelInsuranceJourney {
    public static func travelCertificatePush() -> some JourneyPresentation {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        return
            TravelInsuranceFlowJourney.list(
                canAddTravelInsurance: store.state.canCreateTravelInsurance,
                style: .default,
                infoButtonPlacement: .navigationBarTrailing
            )
            .showsBackButton
    }
    public static func travelCertificateModally() -> some JourneyPresentation {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        return
            TravelInsuranceFlowJourney.list(
                canAddTravelInsurance: store.state.canCreateTravelInsurance,
                style: .modally(presentationStyle: .overFullScreen),
                infoButtonPlacement: .navigationBarLeading
            )
            .withJourneyDismissButton
    }
}
