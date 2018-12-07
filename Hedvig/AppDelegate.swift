//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Flow
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

        HedvigApolloClient.shared.initClient().onValue { client in
            let marketing = Marketing(client: client)

            let marketingPresentation = Presentation(
                marketing,
                style: .marketing,
                options: .defaults
            ).onValue({ _ in
                // self.bag += self.navigationController.present(chatPresentation)
            })

            self.bag += self.navigationController.present(marketingPresentation)
            self.window.makeKeyAndVisible()
        }

        return true
    }
}
