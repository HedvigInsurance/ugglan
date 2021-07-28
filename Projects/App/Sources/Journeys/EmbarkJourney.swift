//
//  EmbarkJourney.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-28.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Embark
import Presentation
import Offer

extension AppJourney {
    static func embark<OfferResultJourney: JourneyPresentation>(
        _ embark: Embark,
        @JourneyBuilder offerResultJourney: @escaping (_ result: OfferResult) -> OfferResultJourney
    ) -> some JourneyPresentation {
        Journey(embark) { externalRedirect in
            switch externalRedirect {
            case .mailingList:
                ContinueJourney()
            case .chat:
                Journey(FreeTextChat(), style: .detented(.large)).withDismissButton
            case .close:
                DismissJourney()
            case let .offer(ids):
                Journey(
                    Offer(
                        offerIDContainer:
                            .exact(
                                ids:
                                    ids,
                                shouldStore:
                                    false
                            ),
                        menu: embark.menu,
                        options: [
                            .menuToTrailing
                        ]
                    )
                ) { offerResult in
                    offerResultJourney(offerResult)
                }
                .onDismiss {
                    embark.goBack()
                }
            case let .menu(action):
                action.journey
            }
        }
    }
}
