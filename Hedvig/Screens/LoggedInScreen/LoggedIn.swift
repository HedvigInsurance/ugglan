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

struct LoggedIn {
    let client: ApolloClient
}

extension LoggedIn: Presentable {
    func materialize() -> (UITabBarController, Disposable) {
        let tabBarController = UITabBarController()

        let bag = DisposeBag()

        let chat = Chat()
        let profile = Profile(client: client)

        let chatPresentation = Presentation(
            chat,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let profilePresentation = Presentation(
            profile,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let newChatPresentation = chatPresentation.addConfiguration { viewController, _ in
            if let navigationController = viewController.navigationController {
                navigationController.tabBarItem = UITabBarItem(title: "Chat", image: nil, selectedImage: nil)
            }
        }

        let configuredProfilePresentation = profilePresentation.addConfiguration { viewController, _ in
            if let navigationController = viewController.navigationController {
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
