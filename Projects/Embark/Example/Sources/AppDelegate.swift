import Apollo
import ApolloWebSocket
import Embark
import EmbarkTesting
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        showStoryList()

        return true
    }

    func showStoryList() {
        ApolloClient.saveToken(token: "tBmMTBw4OAPC5w==.TNrYtXtgMrDzxw==.KyJBBOTLaw1/Pg==")

        ApolloClient.initClient().onValue { store, client in
            let navigationController = UINavigationController()
            navigationController.navigationBar.prefersLargeTitles = true
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()

            Dependencies.shared.add(module: Module {
                client
            })

            Dependencies.shared.add(module: Module {
                store
            })

            Localization.Locale.currentLocale = .en_NO
            DefaultStyling.installCustom()

            self.bag += navigationController.present(
                StoryList(),
                options: [.defaults, .largeTitleDisplayMode(.never)]
            )
        }
    }

    func showDebug() {
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        bag += navigationController.present(Debug(), style: .default, options: [.largeTitleDisplayMode(.always)])
    }
}
