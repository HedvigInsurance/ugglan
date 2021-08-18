import Flow
import Foundation
import Market
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    static var main: some JourneyPresentation {
        GroupJourney {
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
        .onAction(UgglanStore.self) { action in
            if action == .showLoggedIn {
                AppJourney.loggedIn
            }
        }
    }
}
