import Foundation
import Offer
import Payment
import Presentation
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder static var offerCheckout: some JourneyPresentation {
        let store: OfferStore = globalPresentableStoreContainer.get()

        PaymentSetup(
            setupType: .preOnboarding(
                monthlyNetCost: store.state.currentVariant?.bundle.bundleCost.monthlyNet
            )
        )
        .journey { success, paymentConnectionID in
            if let paymentConnectionID = paymentConnectionID {
                Journey(
                    Checkout(paymentConnectionID: paymentConnectionID),
                    style: .default,
                    options: [
                        .defaults,
                        .autoPop,
                        .prefersLargeTitles(true),
                        .largeTitleDisplayMode(.always),
                        .allowSwipeDismissAlways,
                    ]
                ) { _ in
                    DismissJourney()
                }
                .withJourneyDismissButton
                .hidesBackButton
            }
        }
        .setOptions([.defaults, .allowSwipeDismissAlways])
        .mapJourneyDismissToCancel
    }
}
