import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct OnboardingJourney {
	static var journey: some JourneyPresentation {
		MarketGroupJourney { market in
			switch market {
			case .se:
				Journey(OnboardingChat()) { result in
					result.journey
				}
			case .dk:
				Journey(WebOnboarding(webScreen: .webOnboarding)) { value in
					PostOnboardingJourney.journey
				}
			case .no:
				EmbarkOnboardingJourney.journey
			}
		}
		.onPresent {
			ApplicationState.preserveState(.onboarding)
		}
	}
}
