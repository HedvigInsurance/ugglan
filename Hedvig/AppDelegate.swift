//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Disk
import Flow
import Form
import Presentation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window.rootViewController = navigationController

        let hasLoadedCallbacker = Callbacker<Void>()

        let launch = Launch(
            hasLoadedSignal: hasLoadedCallbacker.signal()
        )

        let launchPresentation = Presentation(
            launch,
            style: .modally(
                presentationStyle: .overCurrentContext,
                transitionStyle: .none,
                capturesStatusBarAppearance: true
            ),
            options: [.unanimated, .prefersNavigationBarHidden(true)]
        )

        bag += navigationController.present(launchPresentation)
        window.makeKeyAndVisible()

        let apolloEnvironment = HedvigApolloEnvironmentConfig(
            endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!
        )

        DefaultStyling.installCustom()

        let token = AuthorizationToken(token: "a8Za/PaA2jQqsg==.Lt9hKLFD8+oFBg==.hEprAa/drNxv5g==")
        try? Disk.save(token, to: .applicationSupport, as: "authorization-token.json")

        HedvigApolloClient.shared.initClient(environment: apolloEnvironment).onValue { client in
            HedvigApolloClient.shared.client = client

            let marketing = Marketing(client: client)

            let marketingPresentation = Presentation(
                marketing,
                style: .marketing,
                options: .defaults
            ).onValue({ _ in
                let loggedIn = LoggedIn(client: client)
                self.bag += self.window.present(loggedIn, options: [], animated: true)
            })

            self.bag += self.navigationController.present(marketingPresentation)

            hasLoadedCallbacker.callAll()

            TranslationsRepo.fetch(client: client)
        }

        return true
    }
}
