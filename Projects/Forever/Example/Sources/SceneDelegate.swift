import Flow
import Form
import Foundation
import UIKit
import hCore

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

      let navigationController = UINavigationController()
      navigationController.navigationBar.prefersLargeTitles = true

      window.rootViewController = navigationController
      window.makeKeyAndVisible()

      bag += navigationController.present(
        Debug(),
        style: .default,
        options: [.largeTitleDisplayMode(.always)]
      )
    }
  }

  func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    return scene.userActivity
  }
}
