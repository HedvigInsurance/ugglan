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
            case .no, .dk, .fr:
                EmbarkOnboardingJourney.journey
            }
        }
        .onPresent {
            ApplicationState.preserveState(.onboarding)
        }
    }
}
