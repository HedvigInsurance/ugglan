import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import EmbarkTesting

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
                        Debug(),
                        options: [.defaults, .largeTitleDisplayMode(.never)]
                    )
                }
        }
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
}
