import Foundation
import SwiftUI

extension UIView {
    // recursively goes through all superviews and calls layoutIfNeeded()
    public func layoutSuperviewsIfNeeded() {
        superview?.layoutIfNeeded()
        superview?.layoutSuperviewsIfNeeded()
    }
}
