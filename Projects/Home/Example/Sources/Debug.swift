//
//  Debug.swift
//  HomeExample
//
//  Created by sam on 1.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import ExampleUtil
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Home
import HomeTesting
import Presentation
import UIKit

struct Debug {}

extension Debug: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = "HomeExample"

        let form = FormView()

        ContextGradient.currentOption = .home

        let section = form.appendSection(headerView: UILabel(value: "Screens", style: .default), footerView: nil)

        bag += section.appendRow(title: "Home - Active").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActive()))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            viewController.present(Home(), style: .modal, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - Active in future").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActiveInFuture(switchable: true)))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            viewController.present(Home(), style: .modal, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - Pending").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makePending(switchable: true)))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            viewController.present(Home(), style: .modal, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - Pending non switchable").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makePending(switchable: false)))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            viewController.present(Home(), style: .modal, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
