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
import TestingUtil
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

            bag += UIApplication.shared.keyWindow?.present(Home(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - Active in future").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActiveInFuture(switchable: true)))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            bag += UIApplication.shared.keyWindow?.present(Home(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - Pending").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makePending(switchable: true)))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            bag += UIApplication.shared.keyWindow?.present(Home(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - Pending non switchable").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makePending(switchable: false)))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            bag += UIApplication.shared.keyWindow?.present(Home(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Home - With payment card").append(hCoreUIAssets.chevronRight.image).onValue {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: combineMultiple([
                .makeActive(),
                .makePayInMethodStatus(.needsSetup),
            ])))

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            bag += UIApplication.shared.keyWindow?.present(Home(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
