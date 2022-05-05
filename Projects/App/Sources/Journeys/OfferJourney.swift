import Foundation
import Offer
import Payment
import Presentation
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    static var storedOnboardingOffer: some JourneyPresentation {
        Journey(
            Offer(
                menu: Menu(
                    title: nil,
                    children: [
                        MenuChild.appInformation,
                        MenuChild.appSettings,
                        MenuChild.login,
                    ]
                ),
                options: [
                    .menuToTrailing
                ]
            )
        ) { offerResult in
            switch offerResult {
            case .chat:
                AppJourney
                    .freeTextChat()
                    .withDismissButton
            case .signed:
                AppJourney.postOnboarding
            case let .signedQuoteCart(token, _):
                Journey(ApolloClientSaveTokenLoader(accessToken: token)) {
                    AppJourney.postOnboarding
                }
            case .close:
                ContinueJourney()
            case let .menu(action):
                action.journey
            case .openCheckout:
                AppJourney.offerCheckout
            }
        }
    }

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
