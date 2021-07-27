//
//  OnboardingJourney.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-27.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Flow
import UIKit
import hCore
import hCoreUI

struct OnboardingJourney {
    static var journey: some JourneyPresentation {
        GroupJourney {
            switch Localization.Locale.currentLocale.market {
            case .se:
                Journey(OnboardingChat())
            case .dk:
                Journey(WebOnboardingFlow(webScreen: .webOnboarding)) { value in
                    PostOnboardingJourney.journey
                }
            case .no:
                EmbarkOnboardingJourney.journey
            }
        }.onPresent {
            ApplicationState.preserveState(.onboarding)
        }
    }
}
