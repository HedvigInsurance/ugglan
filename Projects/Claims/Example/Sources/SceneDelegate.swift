import Foundation
import SwiftUI
import hCore
import hCoreUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        scene.userActivity
    }
}
