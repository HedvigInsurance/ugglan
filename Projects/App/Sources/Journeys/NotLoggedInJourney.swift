import Foundation
import Market
import Presentation
import hCore
import Flow
import SwiftUI

extension AppJourney {
    static var notLoggedIn: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: NotLoggedInView {
                Launch.shared.completeAnimationCallbacker.callAll()
            },
            options: []
        ) { action in
            if case .onboard = action {
                AppJourney.onboarding()
            } else if case .loginButtonTapped = action {
                AppJourney.login
            }
            else if case .presentLanguageAndMarketPicker = action {
                LanguageAndMarketPickerView().journey()
                    .configureTitle(L10n.loginMarketPickerPreferences)
            }
        }
    }
}
