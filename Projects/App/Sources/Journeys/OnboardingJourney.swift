import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
	static var onboarding: some JourneyPresentation {
		MarketGroupJourney { market in
			switch market {
			case .se:
				Journey(OnboardingChat()) { result in
					result.journey
				}
			case .dk:
				Journey(WebOnboarding(webScreen: .webOnboarding)) { value in
					AppJourney.postOnboarding
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
