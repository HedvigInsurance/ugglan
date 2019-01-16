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

        bag += tabBarController.presentTabs(
            chatPresentation,
            profilePresentation
        )

        return (tabBarController, bag)
    }
}
