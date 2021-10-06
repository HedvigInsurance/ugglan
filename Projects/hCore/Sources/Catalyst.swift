import Foundation
import UIKit

extension UITraitCollection {
    public static var isCatalyst: Bool {
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac
        } else {
            #if targetEnvironment(macCatalyst)
                return true
            #endif

            return false
        }
    }
}
