import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static var claimsJourney: some JourneyPresentation {
        HonestyPledge.journey {
            Journey(
                ClaimsAskForPushnotifications(),
                style: .detented(.large, modally: false)
            ) { _ in
                AppJourney
                    .claimsChat()
                    .withJourneyDismissButton
            }
            .withJourneyDismissButton
        }
    }
}
