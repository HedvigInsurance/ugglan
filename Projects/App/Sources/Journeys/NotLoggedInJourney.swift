import Flow
import Foundation
import Market
import Presentation
import SwiftUI
import hCore

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
            } else if case .presentLanguageAndMarketPicker = action {
                Market.languageAndMarketPicker
            }
        }
    }
}
