import Authentication
import Flow
import Foundation
import Market
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

extension AppJourney {
    static var main: some JourneyPresentation {
        GroupJourney {
            if hAnalyticsExperiment.updateNecessary {
                AppJourney.updateApp.onPresent {
                    Launch.shared.completeAnimationCallbacker.callAll()
                }
            } else {
                switch ApplicationState.currentState {
                case .onboardingChat, .onboarding, .offer:
                    AppJourney.marketPicker
                case .loggedIn:
                    AppJourney.loggedIn.onPresent {
                        Launch.shared.completeAnimationCallbacker.callAll()
                    }
                case .impersonation:
                    AppJourney.impersonationSettings.onPresent {
                        Launch.shared.completeAnimationCallbacker.callAll()
                    }
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
        .onAction(AuthenticationStore.self) { action in
            if action == .navigationAction(action: .impersonation) {
                AppJourney.impersonationSettings.onPresent {
                    Launch.shared.completeAnimationCallbacker.callAll()
                }
            }
        }
    }
}
