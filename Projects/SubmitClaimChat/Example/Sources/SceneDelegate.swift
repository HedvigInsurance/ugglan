import Foundation
import SubmitClaimChat
import SwiftUI
import hCore
import hCoreUI

/// Example app for SubmitClaimChat – runs the real claim chat against a demo client whose
/// flow starts with the redesigned description step (Skriv / Spela in).
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        Localization.Locale.currentLocale.send(.sv_SE)
        Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientAudioDemo() })
        Dependencies.shared.add(
            module: Module { () -> hSubmitClaimFileUploadClient in SubmitClaimFileUploadClientDemo() }
        )
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })

        let window = UIWindow(windowScene: windowScene)
        let demoState = UserDefaults.standard.string(forKey: "demoState")
        window.rootViewController = UIHostingController(rootView: SubmitClaimChatDemoRoot(demoState: demoState))
        self.window = window
        window.makeKeyAndVisible()
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        scene.userActivity
    }
}
