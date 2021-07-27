import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct PostOnboardingJourney {
	static var journey: some JourneyPresentation {
		Journey(PostOnboarding(), options: [.prefersNavigationBarHidden(true)]) { _ in
			Journey(WelcomePager()) { _ in
				MainTabbedJourney.journey.onPresent {
					AskForRating().ask()
				}
			}
		}
	}
}
