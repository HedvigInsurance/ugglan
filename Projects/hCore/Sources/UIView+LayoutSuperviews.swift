import Foundation
import UIKit

public extension UIView {
    // recursively goes through all superviews and calls layoutIfNeeded()
    func layoutSuperviewsIfNeeded() {
        superview?.layoutIfNeeded()
        superview?.layoutSuperviewsIfNeeded()
    }
}
