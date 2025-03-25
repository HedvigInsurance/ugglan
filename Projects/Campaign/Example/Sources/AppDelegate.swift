import Foundation
import SwiftUI
import hCoreUI

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    internal func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = hNavigationController()
        window?.makeKeyAndVisible()
        return true
    }
}
