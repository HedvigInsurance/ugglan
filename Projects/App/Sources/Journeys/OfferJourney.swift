import Foundation
import Offer
import Presentation

extension AppJourney {
	static var storedOnboardingOffer: some JourneyPresentation {
		Journey(
			Offer(
				offerIDContainer: .stored,
				menu: nil,
				options: [
					.menuToTrailing
				]
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
				AppJourney.postOnboarding
			case .close:
				ContinueJourney()
			case let .menu(action):
				action.journey
			}
		}
	}
}
