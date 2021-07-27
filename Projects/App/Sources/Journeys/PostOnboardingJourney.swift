import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
	static var postOnboarding: some JourneyPresentation {
		Journey(PostOnboarding(), options: [.prefersNavigationBarHidden(true)]) { _ in
			Journey(WelcomePager()) { _ in
                AppJourney.loggedIn.onPresent {
					AskForRating().ask()
				}
			}
		}
	}
}
