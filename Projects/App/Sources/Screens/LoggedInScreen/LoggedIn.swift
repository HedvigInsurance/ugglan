//
//  LoggedIn.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Contracts
import Flow
import Forever
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Home
import Mixpanel
import Presentation
import UIKit

struct LoggedIn {
    @Inject var client: ApolloClient
    let didSign: Bool

    init(didSign: Bool = false) {
        self.didSign = didSign
    }
}

extension Notification.Name {
    static let shouldOpenReferrals = Notification.Name("shouldOpenReferrals")
}

extension LoggedIn {
    func handleOpenReferrals(tabBarController: UITabBarController) -> Disposable {
        NotificationCenter.default.signal(forName: .shouldOpenReferrals).onValue { _ in
            tabBarController.selectedIndex = 3
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

        let home = Home()
        let contracts = Contracts()
        let keyGear = KeyGearOverview()
        let referrals = Forever(service: ForeverServiceGraphQL())
        let profile = Profile()

        let homePresentation = Presentation(
            home,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

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

        bag += client.fetch(
            query: GraphQL.FeaturesQuery(),
            cachePolicy: .fetchIgnoringCacheData
        ).valueSignal.compactMap { $0.data?.member.features }.onValue { features in
            if features.contains(.keyGear) {
                if features.contains(.referrals) {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        keyGearPresentation,
                        referralsPresentation,
                        profilePresentation
                    )
                } else {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        keyGearPresentation,
                        profilePresentation
                    )
                }
            } else {
                if features.contains(.referrals) {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        referralsPresentation,
                        profilePresentation
                    )
                } else {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
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
                .watch(query: GraphQL.WelcomeQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()))
                .compactMap { $0.data }
                .filter { $0.welcome.count > 0 }
                .onValue { data in
                    let welcome = Welcome(data: data, endWithReview: true)
                    tabBarController.present(welcome, style: .detented(.large), options: [.prefersNavigationBarHidden(true)])
                }
        } else if appVersion.compare(lastNewsSeen, options: .numeric) == .orderedDescending {
            bag += client
                .watch(query: GraphQL.WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: lastNewsSeen))
                .compactMap { $0.data }
                .filter { $0.news.count > 0 }
                .onValue { data in
                    let whatsNew = WhatsNew(data: data)
                    tabBarController.present(whatsNew, style: .detented(.large), options: [.prefersNavigationBarHidden(true)])
                }
        }

        bag += handleOpenReferrals(tabBarController: tabBarController)

        bag += tabBarController.signal(for: \.selectedViewController).atOnce().onValue { viewController in
            switch tabBarController.selectedIndex {
            case 0:
                ContextGradient.currentOption = .home
            case 1:
                ContextGradient.currentOption = .insurance
            case 2:
                ContextGradient.currentOption = .forever
            case 3:
                ContextGradient.currentOption = .profile
            default:
                break
            }

            if let debugPresentationTitle = viewController?.debugPresentationTitle {
                Mixpanel.mainInstance().track(event: "SCREEN_VIEW_\(debugPresentationTitle)")
            }
        }

        bag += ChatState.shared.activateNewMessageToasts(tabBarController)

        return (tabBarController, bag)
    }
}
