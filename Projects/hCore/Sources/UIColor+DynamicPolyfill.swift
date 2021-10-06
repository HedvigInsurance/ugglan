import Foundation
import UIKit

extension UIColor {
    public convenience init(
        light: UIColor,
        dark: UIColor
    ) {
        if #available(iOS 13, *) {
            self.init(dynamicProvider: { trait in if trait.userInterfaceStyle == .dark { return dark }

                return light
            })
            return
        }

        self.init(cgColor: light.cgColor)
    }

    public convenience init(
        dynamic: @escaping (_ trait: UITraitCollection) -> UIColor
    ) {
        if #available(iOS 13, *) {
            self.init(dynamicProvider: dynamic)
            return
        }

        self.init(cgColor: dynamic(UITraitCollection()).cgColor)
    }
}
