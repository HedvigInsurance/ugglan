import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static var deleteAccountJourney: some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: DeleteAccountView()
        ) { action in
            if action == .openChat {
                AppJourney.freeTextChat()
            }
        }
        .setStyle(.detented(.large))
        .withJourneyDismissButton
    }
}
