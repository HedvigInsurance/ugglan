import Flow
import Foundation
import UIKit
import hCoreUI

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
            let navigationController = hNavigationController()
            navigationController.navigationBar.prefersLargeTitles = true

            window.rootViewController = navigationController

            bag += navigationController.present(
                Debug.journey
            )

            window.makeKeyAndVisible()
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
}
