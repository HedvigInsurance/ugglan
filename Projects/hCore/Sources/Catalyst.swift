import Foundation
import UIKit

extension UITraitCollection {
    public static var isCatalyst: Bool {
        return ProcessInfo.processInfo.isiOSAppOnMac
    }
}
