import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static func claimsJourney() -> some JourneyPresentation {
        HonestyPledge.journey {
            AppJourney.notificationJourney {
                AppJourney.embark(Embark(name: "claims"), storeOffer: false) { result in
                    switch result {
                    case .chat:
                        AppJourney.claimsChat().withDismissButton
                    case .close:
                        DismissJourney()
                    case .menu:
                        ContinueJourney()
                    case .signed:
                        DismissJourney()
                    }
                }
                .hidesBackButton
            }
            .withJourneyDismissButton
        }
    }
}

extension AppJourney {
    static func notificationJourney<Next: JourneyPresentation>(@JourneyBuilder _ next: @escaping () -> Next) -> some JourneyPresentation {
        Journey(NotificationLoader(), style: .detented(.large)) { authorization in
            switch authorization {
            case .notDetermined:
                Journey(
                    ClaimsAskForPushnotifications(),
                    style: .detented(.large, modally: false)
                ) { _ in
                    next()
                }
            default:
                next()
            }
        }
    }
}
