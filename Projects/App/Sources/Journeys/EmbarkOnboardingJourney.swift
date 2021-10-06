import Embark
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI

struct EmbarkOnboardingJourney {
    public static var journey: some JourneyPresentation {
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
                        )
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
                    }
                }
            }
        }
        .addConfiguration { presenter in
            presenter.viewController.navigationItem.largeTitleDisplayMode = .always
        }
    }
}
