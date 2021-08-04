//
//  ClaimsJourney.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-08-04.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static var claimsJourney: some JourneyPresentation {
        Journey(
            HonestyPledge(),
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        ) { _ in
            Journey(
                ClaimsAskForPushnotifications(),
                style: .detented(.large, modally: false)
            ) { _ in
                Journey(
                    ClaimsChat()
                ).withJourneyDismissButton
            }.withJourneyDismissButton
        }.withDismissButton
    }
}
