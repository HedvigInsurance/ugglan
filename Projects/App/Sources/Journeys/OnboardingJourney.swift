import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import Embark

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
