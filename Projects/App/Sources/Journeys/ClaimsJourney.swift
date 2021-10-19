import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import Embark

extension AppJourney {
    static func claimsJourney(name: String) -> some JourneyPresentation {
        HonestyPledge.journey {
            
            AppJourney.embark(Embark(name: name), storeOffer: false) { result in
                switch result {
                case .chat:
                    AppJourney.freeTextChat().withDismissButton
                case .close:
                    DismissJourney()
                case .menu:
                    ContinueJourney()
                case .signed:
                    Journey(
                        ClaimsAskForPushnotifications(),
                        style: .detented(.large, modally: false)
                    ) { _ in
                        DismissJourney()
                    }
                }
            }
            .withJourneyDismissButton
        }
    }
}
