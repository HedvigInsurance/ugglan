import Foundation
import UIKit

extension UIBarButtonItem {
    public var bounds: CGRect? {
        guard let view = value(forKey: "view") as? UIView else { return nil }
        return view.bounds
    }

    public var view: UIView? {
        guard let view = value(forKey: "view") as? UIView else { return nil }
        return view
    }
}
