import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import Home

extension AppJourney {
    static func claimsJourney<RedirectJourney: JourneyPresentation>(@JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney) -> some JourneyPresentation {
        HonestyPledge.journey {
            AppJourney.notificationJourney {
                let embark = Embark(name: "claims")
                
                AppJourney.embark(embark, redirectJourney: redirectJourney)
            }
            .withJourneyDismissButton
        }
    }
}

extension AppJourney {
    static func notificationJourney<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
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

extension AppJourney {
    static func embark<RedirectJourney: JourneyPresentation>(
        _ embark: Embark,
        style: PresentationStyle = .default,
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        Journey(embark, style: style) { redirect in
            redirectJourney(redirect)
        }
    }
}
