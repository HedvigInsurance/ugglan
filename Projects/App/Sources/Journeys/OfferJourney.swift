//
//  OfferJourney.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-27.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Offer

extension AppJourney {
    static var storedOnboardingOffer: some JourneyPresentation {
        Journey(Offer(
            offerIDContainer: .stored,
            menu: nil,
            options: [
                .menuToTrailing
            ]
        )) { offerResult in
            switch offerResult {
            case .chat:
                Journey(
                    FreeTextChat(),
                    style: .detented(.large),
                    options: [.defaults]
                )
                .withDismissButton
            case .signed:
                AppJourney.postOnboarding
            case .close:
                ContinueJourney()
            case let .menu(action):
                action.journey
            }
        }
    }
}
