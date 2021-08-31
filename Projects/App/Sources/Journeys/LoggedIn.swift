import Contracts
import Flow
import Forever
import Form
import Foundation
import Home
import Payment
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
    fileprivate static var homeTab: some JourneyPresentation {
        Journey(
            Home(),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        ) { result in
            switch result {
            case .startMovingFlow:
                AppJourney.movingFlow
            case .openClaims:
                AppJourney.claimsJourney
            case .openFreeTextChat:
                AppJourney.freeTextChat()
            case .openConnectPayments:
                AppJourney.paymentSetup
            }
        }
        .configureTabBarItem
        .onTabSelected {
            ContextGradient.currentOption = .home
        }
    }

    fileprivate static var contractsTab: some JourneyPresentation {
        Journey(
            Contracts(),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        ) { result in
            switch result {
            case .movingFlow:
                AppJourney.movingFlow
            case .openFreeTextChat:
                AppJourney.freeTextChat()
            }
        }
        .configureTabBarItem
        .onTabSelected {
            ContextGradient.currentOption = .none
        }
    }

    fileprivate static var keyGearTab: some JourneyPresentation {
        Journey(
            KeyGearOverview(),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        )
        .configureTabBarItem
        .onTabSelected {
            ContextGradient.currentOption = .none
        }
    }

    fileprivate static var foreverTab: some JourneyPresentation {
        Journey(
            Forever(service: ForeverServiceGraphQL()),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        )
        .configureTabBarItem
        .onTabSelected {
            ContextGradient.currentOption = .forever
        }
        .makeTabSelected(UgglanStore.self) { action in
            action == .makeForeverTabActive
        }
    }

    fileprivate static var profileTab: some JourneyPresentation {
        Journey(
            Profile(),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        )
        .configureTabBarItem
        .onTabSelected {
            ContextGradient.currentOption = .profile
        }
    }

    static var loggedIn: some JourneyPresentation {
        Journey(FeaturesLoader(), options: []) { features in
            TabbedJourney(
                {
                    homeTab
                },
                {
                    contractsTab
                },
                {
                    if features.contains(.keyGear) {
                        keyGearTab
                    }
                },
                {
                    if features.contains(.referrals) {
                        foreverTab
                    }
                },
                {
                    profileTab
                }
            )
            .syncTabIndex()
            .onAction(UgglanStore.self) { action in
                if action == .openChat {
                    AppJourney.freeTextChat()
                }
            }
        }
        .onPresent {
            ApplicationState.preserveState(.loggedIn)
            AnalyticsCoordinator().setUserId()

            if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
                UIApplication.shared.appDelegate.registerFCMToken(fcmToken)
            }
        }
    }
}
