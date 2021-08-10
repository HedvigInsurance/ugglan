import Foundation
import UIKit
import SwiftUI
import Presentation
import hCoreUI
import Form
import Flow

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DefaultStyling.installCustom()
        return true
    }
}
