import Foundation
import UIKit

public extension UIColor {
    convenience init(dynamic: @escaping (_ trait: UITraitCollection) -> UIColor) {
        if #available(iOS 13, *) {
            self.init(dynamicProvider: dynamic)
            return
        }

        self.init(cgColor: dynamic(UITraitCollection()).cgColor)
    }
}
