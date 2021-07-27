import Flow
import Foundation
import Market
import Presentation
import UIKit
import hCore
import hCoreUI

struct MainJourney {
	static var journey: some JourneyPresentation {
		Journey(MarketPicker()) { _ in
			Journey(Marketing()) { marketingResult in
				switch marketingResult {
				case .onboard:
					OnboardingJourney.journey
				case .login:
					LoginJourney.journey
				}
			}
		}
	}
}
