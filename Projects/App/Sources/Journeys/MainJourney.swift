import Flow
import Foundation
import Market
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI
import hAnalytics

extension AppJourney {
    static var main: some JourneyPresentation {
        GroupJourney {
            if hAnalyticsExperiment.updateNecessary {
                AppJourney.updateApp
            } else {
                switch ApplicationState.currentState {
                case .onboardingChat, .onboarding:
                    AppJourney.onboarding
                case .offer:
                    AppJourney.storedOnboardingOffer
                case .loggedIn:
                    AppJourney.loggedIn
                default:
                    AppJourney.marketPicker
                }
            }
        }
        .onAction(UgglanStore.self) { action in
            if action == .showLoggedIn {
                AppJourney.loggedIn
            }
        }
    }
}
