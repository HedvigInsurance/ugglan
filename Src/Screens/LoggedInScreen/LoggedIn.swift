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
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let lastNewsSeen = UserDefaults.standard.string(forKey: WhatsNew.lastNewsSeenKey) ?? "0.0.0"
        
        if appVersion.compare(lastNewsSeen, options: .numeric) == .orderedDescending {
            bag += client
                .watch(query: WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: lastNewsSeen))
                .filter(predicate: { $0.data != nil && $0.data!.news.count > 0 })
                .compactMap { $0.data }
                .onValue { data in
                    let whatsNew = WhatsNew(data: data)
                    tabBarController.present(whatsNew)
                }
            
        }

        return (tabBarController, bag)
    }
}
