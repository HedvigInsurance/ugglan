//
//  MarketJourney.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-27.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Market

extension AppJourney {
    static var marketPicker: some JourneyPresentation {
        Journey(MarketPicker()) { _ in
            Journey(Marketing()) { marketingResult in
                switch marketingResult {
                case .onboard:
                    AppJourney.onboarding
                case .login:
                    AppJourney.login
                }
            }
        }
    }
}
