//
//  LoggedIn.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import Mixpanel

struct LoggedIn {
    @Inject var client: ApolloClient
    let didSign: Bool

    init(didSign: Bool = false) {
        self.didSign = didSign
    }
}

extension LoggedIn {
    func handleOpenReferrals(tabBarController: UITabBarController) -> Disposable {
        return NotificationCenter.default.signal(forName: .shouldOpenReferrals).onValue { _ in
            tabBarController.selectedIndex = 2
        }
    }
}

extension LoggedIn: Presentable {
    func materialize() -> (UITabBarController, Disposable) {
        let tabBarController = UITabBarController()
        let loadingViewController = UIViewController()
        loadingViewController.view.backgroundColor = .primaryBackground
        tabBarController.viewControllers = [loadingViewController]

        ApplicationState.preserveState(.loggedIn)

        let bag = DisposeBag()

        let contracts = Contracts()
        let keyGear = KeyGearOverview()
        let claims = Claims()
        let referrals = Referrals()
        let profile = Profile()

        let contractsPresentation = Presentation(
            contracts,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let keyGearPresentation = Presentation(
            keyGear,
            style: .default,
            options: [.prefersLargeTitles(true)]
        )

        let claimsPresentation = Presentation(
            claims,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let referralsPresentation = Presentation(
            referrals,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let profilePresentation = Presentation(
            profile,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        bag += client.fetch(query: FeaturesQuery()).valueSignal.compactMap { $0.data?.member.features }.onValue { features in
            if features.contains(.keyGear) {
                if features.contains(.referrals) {
                    bag += tabBarController.presentTabs(
                        contractsPresentation,
                        keyGearPresentation,
                        claimsPresentation,
                        referralsPresentation,
                        profilePresentation
                    )
                } else {
                    bag += tabBarController.presentTabs(
                        contractsPresentation,
                        keyGearPresentation,
                        claimsPresentation,
                        profilePresentation
                    )
                }
            } else {
                if features.contains(.referrals) {
                    bag += tabBarController.presentTabs(
                        contractsPresentation,
                        claimsPresentation,
                        referralsPresentation,
                        profilePresentation
                    )
                } else {
                    bag += tabBarController.presentTabs(
                        contractsPresentation,
                        claimsPresentation,
                        profilePresentation
                    )
                }
            }
        }

        let appVersion = Bundle.main.appVersion
        let lastNewsSeen = ApplicationState.getLastNewsSeen()

        if didSign {
            ApplicationState.setLastNewsSeen()

            bag += client
                .watch(query: WelcomeQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()))
                .compactMap { $0.data }
                .filter { $0.welcome.count > 0 }
                .onValue { data in
                    let whatsNew = Welcome(data: data, endWithReview: true)
                    tabBarController.present(whatsNew, options: [.prefersNavigationBarHidden(true)])
                }
        } else if appVersion.compare(lastNewsSeen, options: .numeric) == .orderedDescending {
            bag += client
                .watch(query: WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: lastNewsSeen))
                .compactMap { $0.data }
                .filter { $0.news.count > 0 }
                .onValue { data in
                    let whatsNew = WhatsNew(data: data)
                    tabBarController.present(whatsNew, options: [.prefersNavigationBarHidden(true)])
                }
        }

        bag += handleOpenReferrals(tabBarController: tabBarController)
        
        bag += tabBarController.signal(for: \.selectedViewController).onValue { viewController in
            if let debugPresentationTitle = viewController?.debugPresentationTitle {
                Mixpanel.mainInstance().track(event: "SCREEN_VIEW_\(debugPresentationTitle)")
            }
        }

        return (tabBarController, bag)
    }
}
