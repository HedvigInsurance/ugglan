import Foundation
import Payment
import Presentation

extension AppJourney {
    static func paymentSetup<Next: JourneyPresentation>(@JourneyBuilder _ next: @escaping (_ success: Bool) -> Next) -> some JourneyPresentation {
        Journey(
            PaymentSetup(setupType: .initial, urlScheme: Bundle.main.urlScheme ?? ""),
            style: .detented(.large)
        ) { success in
            next(success)
        }
    }
}
