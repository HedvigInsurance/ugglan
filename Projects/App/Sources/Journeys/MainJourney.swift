//
//  MainJourney.swift
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
import Market

struct MainJourney {
    static var journey: some JourneyPresentation {
        Journey(MarketPicker()) { _ in
            Journey(Marketing()) { marketingResult in
                switch marketingResult {
                case .onboard:
                    OnboardingJourney.journey
                case .login:
                    Journey(Login(), style: .detented(.large))
                }
            }
        }
    }
}
