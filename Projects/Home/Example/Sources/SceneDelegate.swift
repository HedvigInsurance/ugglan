import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let bag = DisposeBag()
    var window: UIWindow?

    func run() {
        DefaultStyling.installCustom()

        Localization.Locale.currentLocale = .en_SE

        let navigationController = hNavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTouchesRequired = 3

        bag += tapGestureRecognizer.signal(forState: .recognized)
            .onValue { _ in self.bag.dispose()
                self.run()
            }

        window?.addGestureRecognizer(tapGestureRecognizer)

        bag += { self.window?.removeGestureRecognizer(tapGestureRecognizer) }

        bag += navigationController.present(DebugView.journey)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        ApplicationContext.shared.hasFinishedBootstrapping = true
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            run()
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
}
