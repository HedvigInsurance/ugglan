import Contracts
import Embark
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
                AppJourney.claimJourney
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
        .makeTabSelected(UgglanStore.self) { action in
            if case .makeTabActive(let deepLink) = action {
                return deepLink == .home
            } else {
                return false
            }
        }
    }
    
    fileprivate static var contractsTab: some JourneyPresentation {
        Contracts.journey { result in
            switch result {
            case .movingFlow:
                AppJourney.movingFlow
            case .openFreeTextChat:
                AppJourney.freeTextChat()
            case let .openCrossSellingDetail(crossSell):
                AppJourney.crossSellingJourney(crossSell: crossSell)
            case let .openCrossSellingEmbark(name):
                AppJourney.crossSellingEmbarkJourney(name: name, style: .detented(.large))
            }
        }
        .onTabSelected {
            ContextGradient.currentOption = .none
        }
        .makeTabSelected(UgglanStore.self) { action in
            if case .makeTabActive(let deepLink) = action {
                return deepLink == .insurances
            } else {
                return false
            }
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
                if case .makeTabActive(let deepLink) = action {
                    return deepLink == .forever
                } else {
                    return false
                }
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
            .makeTabSelected(UgglanStore.self) { action in
                if case .makeTabActive(let deepLink) = action {
                    return deepLink == .profile
                } else {
                    return false
                }
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
                    } else if action == .openClaims {
                        AppJourney.claimJourney
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

extension JourneyPresentation {
    func sendActionOnValue<S: Store>(
        _ storeType: S.Type,
        _ action: S.Action
    ) -> Self {
        let store: S = self.presentable.get()
        
        store.send(action)
        
        return self
    }
}

