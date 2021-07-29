import Payment
import Presentation
import Foundation

extension AppJourney {
    static var paymentSetup: some JourneyPresentation {
        Journey(PaymentSetup(setupType: .initial, urlScheme: Bundle.main.urlScheme ?? ""), style: .detented(.large))
    }
}
