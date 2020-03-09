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
import Common
import Space

struct LoggedIn {
    @Inject var client: ApolloClient
    @Inject var remoteConfig: RemoteConfigContainer
    let didSign: Bool

    init(didSign: Bool = false) {
        self.didSign = didSign
    }
}

extension LoggedIn {
    func handleTerminatedInsurances(tabBarController: UITabBarController) -> Disposable {
        return client
            .fetch(query: InsuranceStatusQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.status }
            .filter { $0 == .terminated }
            .toVoid()
            .onValue {
                tabBarController.present(TerminatedInsurance(), options: [.prefersNavigationBarHidden(true)])
            }
    }

    func handleOpenReferrals(tabBarController: UITabBarController) -> Disposable {
        return NotificationCenter.default.signal(forName: .shouldOpenReferrals).onValue { _ in
            tabBarController.selectedIndex = 2
        }
    }
}

extension LoggedIn: Presentable {
    func materialize() -> (UITabBarController, Disposable) {
        let tabBarController = UITabBarController()

        ApplicationState.preserveState(.loggedIn)

        let bag = DisposeBag()

        let dashboard = Dashboard()
        let keyGear = KeyGearOverview()
        let claims = Claims()
        let referrals = Referrals()
        let profile = Profile()

        let dashboardPresentation = Presentation(
            dashboard,
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
                bag += tabBarController.presentTabs(
                    dashboardPresentation,
                    keyGearPresentation,
                    claimsPresentation,
                    referralsPresentation,
                    profilePresentation
                )
            } else {
                bag += tabBarController.presentTabs(
                    dashboardPresentation,
                    claimsPresentation,
                    referralsPresentation,
                    profilePresentation
                )
            }
        }

        let appVersion = Bundle.main.appVersion
        let lastNewsSeen = ApplicationState.getLastNewsSeen()

        if didSign {
            ApplicationState.setLastNewsSeen(appVersion: Bundle.main.appVersion)

            bag += client
                .watch(query: WelcomeQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()))
                .compactMap { $0.data }
                .filter { $0.welcome.count > 0 }
                .onValue { data in
                    let whatsNew = Welcome(data: data)
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

        bag += handleTerminatedInsurances(tabBarController: tabBarController)
        bag += handleOpenReferrals(tabBarController: tabBarController)

        return (tabBarController, bag)
    }
}
