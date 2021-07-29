import Foundation
import Presentation

extension AppJourney {
	static var claimsHandler: some JourneyPresentation {
		Journey(
			HonestyPledge(),
			style: .detented(.preferredContentSize),
			options: [
				.defaults, .allowSwipeDismissAlways, .prefersLargeTitles(true),
				.largeTitleDisplayMode(.always),
			]
		)
		.withDismissButton
	}
}
