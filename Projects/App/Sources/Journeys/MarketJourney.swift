import Foundation
import Market
import Presentation

extension AppJourney {
	static var marketPicker: some JourneyPresentation {
		Journey(MarketPicker()) { _ in
			Journey(Marketing()) { marketingResult in
				switch marketingResult {
				case .onboard:
					AppJourney.onboarding
				case .login:
					AppJourney.login
				}
			}
		}
	}
}
