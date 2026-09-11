import Foundation
import SubmitClaimChat
import SwiftUI
import hCore
import hCoreUI

/// Example app for SubmitClaimChat – currently shows the claim input prototype
/// (Figma "Claim input chat", 449:49211).
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        Localization.Locale.currentLocale.send(.sv_SE)
        let window = UIWindow(windowScene: windowScene)
        // Optional launch argument, e.g. `-prototypeState voice`, to open straight into a state.
        let startState = UserDefaults.standard.string(forKey: "prototypeState")
        window.rootViewController = UIHostingController(rootView: ClaimInputPrototypeRoot(startState: startState))
        self.window = window
        window.makeKeyAndVisible()
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        scene.userActivity
    }
}
