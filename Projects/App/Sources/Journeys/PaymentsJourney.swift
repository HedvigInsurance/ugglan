import Foundation
import Payment
import Presentation

extension AppJourney {
    static func paymentSetup<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ success: Bool) -> Next
    ) -> some JourneyPresentation {
        Journey(
            PaymentSetup(setupType: .initial, urlScheme: Bundle.main.urlScheme ?? ""),
            style: .detented(.large),
            options: [.defaults, .autoPopSelfAndSuccessors]
        ) { result in
            if let success = result.left {
                next(success)
            } else if let options = result.right {
                Journey(AdyenPayIn(adyenOptions: options, urlScheme: Bundle.main.urlScheme ?? "")) { success in
                    next(success)
                }
                .withJourneyDismissButton
            }
        }
    }
}
