//
//  CrossSeliingJourney.swift
//  CrossSeliingJourney
//
//  Created by Sam Pettersson on 2021-09-10.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Embark
import Contracts

extension AppJourney {
    static func crossSellingJourney(name: String) -> some JourneyPresentation {
        AppJourney.embark(
            Embark(name: name),
            storeOffer: false,
            style: .detented(.large)
        ) { offerResult in
            switch offerResult {
            case .chat:
                AppJourney.freeTextChat().withDismissButton
            case .close:
                DismissJourney()
            case .menu:
                ContinueJourney()
            case let .signed(_, startDates):
                CrossSellingSigned.journey(startDate: startDates.first?.value)
            }
        }
    }
}
