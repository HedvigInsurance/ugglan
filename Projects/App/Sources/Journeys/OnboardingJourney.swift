import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static var onboarding: some JourneyPresentation {
        EmbarkOnboardingJourney
            .journey
            .onPresent {
                ApplicationState.preserveState(.onboarding)
            }
    }
}
