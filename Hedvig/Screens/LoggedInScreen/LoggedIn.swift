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

extension UITabBarController {
    // swiftlint:disable identifier_name
    func presentTabs<A: Presentable, AMatter: UIViewController, B: Presentable, BMatter: UIViewController>(
        _ a: Presentation<A>,
        _ b: Presentation<B>
    ) -> Disposable where
        A.Matter == AMatter,
        A.Result == Disposable,
        B.Matter == BMatter,
        B.Result == Disposable {
        let bag = DisposeBag()

        let aMaterialized = a.presentable.materialize()
        let bMaterialized = b.presentable.materialize()

        bag += a.transform(aMaterialized.1)
        bag += b.transform(bMaterialized.1)

        let aViewController = aMaterialized.0.embededInNavigationController(a.options)
        let bViewController = bMaterialized.0.embededInNavigationController(b.options)

        a.configure(aMaterialized.0, bag)
        b.configure(bMaterialized.0, bag)

        viewControllers = [aViewController, bViewController]

        return bag
    }

    // swiftlint:enable identifier_name
}

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
