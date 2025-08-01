import Form
import Foundation
import hCoreUI
import Presentation
import SwiftUI

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DefaultStyling.installCustom()
        return true
    }
}
