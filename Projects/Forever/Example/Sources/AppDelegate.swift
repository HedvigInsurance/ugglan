import Flow
import Forever
import Foundation
import SwiftUI
import hCoreUI

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.setup()
        return true
    }
}
