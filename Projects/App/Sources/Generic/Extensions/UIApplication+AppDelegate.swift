import Foundation
import SwiftUI

extension UIApplication {
    var appDelegate: AppDelegate { SharedAppDelegate.appDelegate }
}

private class SharedAppDelegate {
    @UIApplicationDelegateAdaptor(AppDelegate.self) static var appDelegate
}
