//
//  LoggedIn.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation

struct LoggedIn {}

extension LoggedIn: Presentable {
    func materialize() -> (UITabBarController, Disposable) {
        let tabBarController = UITabBarController()

        let bag = DisposeBag()

        let chat = Chat()
        let profile = Profile()

        let chatPresentation = Presentation(
            chat,
            style: .default,
            options: .defaults
        )

        let profilePresentation = Presentation(
            profile,
            style: .default,
            options: .defaults
        )

        let newChatPresentation = chatPresentation.addConfiguration { viewController, _ in
            viewController.title = "Fisk"

            if let navigationController = viewController.navigationController {
                if #available(iOS 11.0, *) {
                    navigationController.navigationBar.prefersLargeTitles = true
                }
                navigationController.tabBarItem = UITabBarItem(title: "Chat", image: nil, selectedImage: nil)
            }
        }

        let configuredProfilePresentation = profilePresentation.addConfiguration { viewController, _ in
            if let navigationController = viewController.navigationController {
                if #available(iOS 11.0, *) {
                    navigationController.navigationBar.prefersLargeTitles = true
                }

                navigationController.tabBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
            }
        }

        bag += tabBarController.presentTabs(
            newChatPresentation,
            configuredProfilePresentation
        )

        return (tabBarController, bag)
    }
}
