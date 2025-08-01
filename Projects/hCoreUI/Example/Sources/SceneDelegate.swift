import Flow
import Foundation
import Presentation
import SwiftUI
import hCoreUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let bag = DisposeBag()
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            let navigationController = hNavigationController()
            navigationController.navigationBar.prefersLargeTitles = true

            window.rootViewController = navigationController

            bag += navigationController.present(hDesignSystem.journey)

            window.makeKeyAndVisible()
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        scene.userActivity
    }
}
