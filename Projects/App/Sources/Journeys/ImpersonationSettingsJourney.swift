import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

extension AppJourney {
    static var impersonationSettings: some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: ImpersonationSettings()
        ) { action in
            if action == .showLoggedIn {
                AppJourney.loggedIn
            }
        }
        .setOptions([.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        .setStyle(.detented(.large))
        .configureTitle("Impersonation")
    }
}
