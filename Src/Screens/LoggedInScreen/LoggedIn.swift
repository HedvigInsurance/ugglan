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

struct LoggedIn {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
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
        let claims = Claims()
        let profile = Profile(client: client)

        let dashboardPresentation = Presentation(
            dashboard,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let claimsPresentation = Presentation(
            claims,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let profilePresentation = Presentation(
            profile,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        bag += tabBarController.presentTabs(
            dashboardPresentation,
            claimsPresentation,
            profilePresentation
        )
        
        let appVersion = Bundle.main.appVersion
        let lastNewsSeen = ApplicationState.getLastNewsSeen()
        
        if "1.0.0".compare("0.9.9", options: .numeric) == .orderedDescending {
            bag += client
                .watch(query: WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: "0.9.9"))
                .filter{ $0.data != nil && $0.data!.news.count > 0 }
                .compactMap { $0.data }
                .onValue { data in
                    var testData = data
                    testData.news.append(data.news[0])
                    testData.news.append(data.news[0])
                    testData.news.append(data.news[0])
                    let whatsNew = WhatsNew(data: testData)
                    tabBarController.present(whatsNew, options: [.prefersNavigationBarHidden(true)])
                }
            
        }

        bag += handleTerminatedInsurances(tabBarController: tabBarController)
        bag += handleOpenReferrals(tabBarController: tabBarController)

        return (tabBarController, bag)
    }
}
