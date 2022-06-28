import Foundation
import UIKit

extension UIColor {
    public convenience init(
        light: UIColor,
        dark: UIColor
    ) {
        self.init(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark { return dark }

            return light
        })
    }

    public convenience init(
        dynamic: @escaping (_ trait: UITraitCollection) -> UIColor
    ) {
        self.init(dynamicProvider: dynamic)
    }
}
