import Foundation
import UIKit

extension UIColor {
    /// create an instance of UIColor that uses elevated colors on UITraitCollection.userInterfaceLevel == .elevated
    public convenience init(
        base: UIColor,
        elevated: UIColor
    ) {
        self.init(dynamic: { trait in
            return trait.userInterfaceLevel == .elevated ? elevated : base
        })
    }
}
