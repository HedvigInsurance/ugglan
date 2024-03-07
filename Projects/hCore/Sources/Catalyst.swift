import Foundation
import SwiftUI

extension UITraitCollection {
    public static var isCatalyst: Bool {
        return ProcessInfo.processInfo.isiOSAppOnMac
    }
}
