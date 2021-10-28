import Embark
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
                embark(Embark(name: "Web Onboarding SE - Switcher Without Accident"), storeOffer: true) { result in
                    ContinueJourney()
                }
            case .no, .dk:
                EmbarkOnboardingJourney.journey
            }
        }
        .onPresent {
            ApplicationState.preserveState(.onboarding)
        }
    }
}
