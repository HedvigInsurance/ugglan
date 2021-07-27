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
			MenuChild.login(onLogin: {
				UIApplication.shared.appDelegate.appFlow.presentLoggedIn()
			}),
		]

		return Journey(EmbarkPlans(menu: Menu(title: nil, children: menuChildren))) { story in
			Embark.makeJourney(
				Embark(
					name: story.name,
					menu: Menu(
						title: nil,
						children: menuChildren
					)
				)
			) { offerResult in
				switch offerResult {
				case .chat:
					Journey(
						FreeTextChat(),
						style: .detented(.large),
						options: [.defaults]
					)
					.withDismissButton
				case .signed:
					PostOnboardingJourney.journey
				case .close:
					ContinueJourney()
				}
			}
		}
		.addConfiguration { presenter in
			presenter.viewController.navigationItem.largeTitleDisplayMode = .always
		}
	}
}
