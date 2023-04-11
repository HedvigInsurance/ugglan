import Claims
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
import hAnalytics
import hCore
import hCoreUI

extension AppJourney {
    fileprivate static var homeTab: some JourneyPresentation {
        let claims = Claims()
        let commonClaims = CommonClaimsView()
        return Journey(
            Home(
                claimsContent: claims,
                commonClaims: commonClaims
            ),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        ) { result in
            switch result {
            case .startMovingFlow:
                AppJourney.movingFlow
            case .openFreeTextChat:
                AppJourney.freeTextChat()
            case .openConnectPayments:
                PaymentSetup(setupType: .initial).journeyThenDismiss
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
        .configureClaimsNavigation
    }

    fileprivate static var contractsTab: some JourneyPresentation {
        Contracts.journey { result in
            switch result {
            case .movingFlow:
                AppJourney.movingFlow
            case .openFreeTextChat:
                AppJourney.freeTextChat().withDismissButton
            case let .openCrossSellingDetail(crossSell):
                AppJourney.crossSellingJourney(crossSell: crossSell)
            case let .openCrossSellingEmbark(name):
                AppJourney.crossSellingEmbarkJourney(name: name, style: .detented(.large))
            case let .openCrossSellingWebUrl(url):
                AppJourney.webRedirect(url: url)
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

    fileprivate static var foreverTab: some JourneyPresentation {
        Journey(
            Forever(service: ForeverServiceGraphQL()),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        )
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
        .configureForeverTabBarItem
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
        .businessModelNavigation
    }

    static var loggedIn: some JourneyPresentation {
        Journey(ExperimentsLoader(), options: []) { _ in
            TabbedJourney(
                {
                    homeTab
                },
                {
                    contractsTab
                },
                {
                    if hAnalyticsExperiment.forever {
                        foreverTab
                    }
                },
                {
                    profileTab
                }
            )
            .sendActionImmediately(ContractStore.self, .fetch)
            .sendActionImmediately(ClaimsStore.self, .fetchClaims)
            .syncTabIndex()
            .onAction(UgglanStore.self) { action in
                if action == .openChat {
                    AppJourney.freeTextChat().withDismissButton
                }
            }
        }
        .onPresent {
            ApplicationState.preserveState(.loggedIn)
            AnalyticsCoordinator().setUserId()
        }
    }
}

extension JourneyPresentation {
    public var configureClaimsNavigation: some JourneyPresentation {
        onAction(ClaimsStore.self) { action in
            if case let .openClaimDetails(claim) = action {
                AppJourney.claimDetailJourney(claim: claim)
            } else if case let .submitNewClaim(origin) = action {
                AppJourney.claimJourney(from: origin)
            } else if case .openFreeTextChat = action {
                AppJourney.freeTextChat()
            } else if case .openHowClaimsWork = action {
                AppJourney.claimsInfoJourney()
            } else if case let .openCommonClaimDetail(commonClaim) = action {
                AppJourney.commonClaimDetailJourney(claim: commonClaim)
            }
        }
    }

    public var businessModelNavigation: some JourneyPresentation {
        onAction(UgglanStore.self) { action in
            if case .businessModelDetail = action {
                AppJourney.businessModelDetailJourney
            }
        }
    }
}
