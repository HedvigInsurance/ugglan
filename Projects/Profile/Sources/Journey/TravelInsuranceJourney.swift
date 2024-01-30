import Foundation
import Presentation
import TravelCertificate
import UIKit

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
        //            .setOptions([.defaults, .ignoreActionWhenNotOnTop])
        ////            .onDismiss {
        ////                let vc = UIApplication.shared.getTopViewController()
        ////                let ss = ""
        ////                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        ////                    let vc = UIApplication.shared.getTopViewController()
        ////                    let ss = ""
        ////                }
        ////            }
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
            .setOptions([.disablePushPopCoalecing, .defaults])
    }
}
