import Foundation
import UIKit

public extension UIColor {
    /// create an instance of UIColor that uses elevated colors on UITraitCollection.userInterfaceLevel == .elevated
    convenience init(base: UIColor, elevated: UIColor) {
        self.init(dynamic: { trait in
            if #available(iOS 13.0, *) {
                return trait.userInterfaceLevel == .elevated ? elevated : base
            } else {
                return base
            }
        })
    }
}
