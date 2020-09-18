import Foundation
import UIKit

public extension UIView {
    /// Workaround for the UIStackView bug where setting hidden to true with animation doesn't work
    var animationSafeIsHidden: Bool {
        get {
            isHidden
        }
        set {
            if isHidden != newValue {
                isHidden = newValue
            }
        }
    }
}
