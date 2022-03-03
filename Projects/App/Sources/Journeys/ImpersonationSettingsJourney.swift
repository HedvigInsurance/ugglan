import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static var impersonationSettings: some JourneyPresentation {
        HostingJourney(UgglanStore.self, rootView: ImpersonationSettings()) { action in
            if action == .showLoggedIn {
                DismissJourney()
            }
        }
        .setOptions([.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        .setStyle(.detented(.large))
        .configureTitle("Impersonation")
    }
}
