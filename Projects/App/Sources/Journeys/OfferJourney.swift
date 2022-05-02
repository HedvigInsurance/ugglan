import Foundation
import Offer
import Payment
import Presentation
import hCore
import hCoreUI

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
            case let .openCheckout(token):
                AppJourney.offerCheckout(with: token)
            case let .openPerilDetail(peril):
                Journey(
                    PerilDetail(peril: peril),
                    style: .detented(.preferredContentSize, .large)
                )
                .withDismissButton
            }
        }
    }

    static func offerCheckout(with token: String? = nil) -> some JourneyPresentation {
        PaymentSetup(setupType: .initial, accessToken: token)
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
