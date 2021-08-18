import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCoreUI

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DefaultStyling.installCustom()
        return true
    }
}
