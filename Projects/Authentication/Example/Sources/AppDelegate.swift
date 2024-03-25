import Apollo
import ExampleUtil
import Flow
import Foundation
import SwiftUI
import TestingUtil
import hCoreUI
import hGraphQL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.setup()

        return true
    }
}
