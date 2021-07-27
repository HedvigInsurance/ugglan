//
//  PostOnboardingJourney.swift
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
