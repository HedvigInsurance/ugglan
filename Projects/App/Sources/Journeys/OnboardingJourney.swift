import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static func onboarding(cartId: String?) -> some JourneyPresentation {
        EmbarkOnboardingJourney
            .journey(cartId: cartId)
            .onPresent {
                ApplicationState.preserveState(.onboarding)
            }
    }
}
