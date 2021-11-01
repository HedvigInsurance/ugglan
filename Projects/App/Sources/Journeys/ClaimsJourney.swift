import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static func claimsJourney(name: String) -> some JourneyPresentation {
        HonestyPledge.journey {
            Journey(
                ClaimsAskForPushnotifications(),
                style: .detented(.large, modally: false)
            ) { _ in
                AppJourney
                    .claimsChat()
                    .withJourneyDismissButton
            }
        }
    }
}
