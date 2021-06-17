//
//  SceneDelegate.swift
//  EmbarkExample
//
//  Created by Sam Pettersson on 2021-06-17.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit
import hCore
import Form
import Apollo

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let bag = DisposeBag()
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            window.makeKeyAndVisible()

            ApolloClient.saveToken(token: "tBmMTBw4OAPC5w==.TNrYtXtgMrDzxw==.KyJBBOTLaw1/Pg==")

            ApolloClient.initClient()
                .onValue { store, client in let navigationController = UINavigationController()
                    navigationController.navigationBar.prefersLargeTitles = true
                    self.window?.rootViewController = navigationController

                    Dependencies.shared.add(module: Module { client })

                    Dependencies.shared.add(module: Module { store })

                    Localization.Locale.currentLocale = .en_NO
                    DefaultStyling.installCustom()

                    self.bag += navigationController.present(
                        StoryList(),
                        options: [.defaults, .largeTitleDisplayMode(.never)]
                    )
                }
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
}

