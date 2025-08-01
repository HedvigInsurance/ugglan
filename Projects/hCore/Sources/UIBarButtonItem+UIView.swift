import Foundation
import SwiftUI

public extension UIBarButtonItem {
    var bounds: CGRect? {
        guard let view = value(forKey: "view") as? UIView else { return nil }
        return view.bounds
    }

    var view: UIView? {
        guard let view = value(forKey: "view") as? UIView else { return nil }
        return view
    }
}
