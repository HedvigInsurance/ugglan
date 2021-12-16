import Foundation
import Offer
import Payment
import Presentation
import hCore

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
            case .close:
                ContinueJourney()
            case let .menu(action):
                action.journey
            case .openCheckout:
                offerCheckout
            }
        }
    }

    static var offerCheckout: some JourneyPresentation {
        PaymentSetup(setupType: .initial)
            .journey { success in
                Journey(
                    Checkout(),
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
            .setOptions([.defaults, .allowSwipeDismissAlways])
            .mapJourneyDismissToCancel
    }
}
