import Form
import Foundation
import Presentation
import SwiftUI
import hCoreUI

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DefaultStyling.installCustom()
        return true
    }
}
