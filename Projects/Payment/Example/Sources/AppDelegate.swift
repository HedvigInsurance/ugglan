import Foundation
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  internal func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = UINavigationController()
    window?.makeKeyAndVisible()
    return true
  }
}
