import ExampleUtil
import Foundation
import SwiftUI
import hCoreUI

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.setup()
        return true
    }
}
