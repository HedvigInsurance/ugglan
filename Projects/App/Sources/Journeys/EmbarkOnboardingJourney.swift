import Embark
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

struct EmbarkOnboardingJourney {
    public static var quoteCartLoaderJourney: some JourneyPresentation {
        GroupJourney {
            if hAnalyticsExperiment.useQuoteCart {
                createQuoteCartOnboarding()
            } else {
                journey(cartId: nil)
            }
        }
    }

    private static func createQuoteCartOnboarding() -> some JourneyPresentation {
        return Journey(
            StoreLoadingPresentable<UgglanStore>(
                action: UgglanAction.createOnboardingQuoteCart,
                endOn: { action in
                    switch action {
                    case .setOnboardingIdentifier:
                        return true
                    default:
                        return false
                    }
                }
            )
        ) { ugglanState in
            EmbarkOnboardingJourney.journey(cartId: ugglanState.onboardingIdentifier)
        }
    }

    private static func journey(cartId: String?) -> some JourneyPresentation {
        let menuChildren: [MenuChildable] = [
            MenuChild.appInformation,
            MenuChild.appSettings,
            MenuChild.login,
        ]

        return Journey(
            EmbarkPlans(menu: Menu(title: nil, children: menuChildren)),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        ) { plansResult in
            switch plansResult {
            case let .menu(action):
                action.journey
            case let .story(story):
                AppJourney.embark(
                    Embark(
                        name: story.name,
                        menu: Menu(
                            title: nil,
                            children: menuChildren
                        ),
                        cartId: cartId
                    ),
                    storeOffer: true
                ) { offerResult in
                    switch offerResult {
                    case .chat:
                        AppJourney.freeTextChat()
                    case .signed:
                        AppJourney.postOnboarding
                    case .close:
                        ContinueJourney()
                    case let .menu(action):
                        action.journey
                    case let .openCheckout(token):
                        AppJourney.offerCheckout(with: token)
                    case let .signedQuoteCart(accessToken, _):
                        Journey(ApolloClientSaveTokenLoader(accessToken: accessToken)) {
                            AppJourney.postOnboarding
                        }
                    }
                }
            }
        }
        .addConfiguration { presenter in
            presenter.viewController.navigationItem.largeTitleDisplayMode = .always
        }
    }
}
