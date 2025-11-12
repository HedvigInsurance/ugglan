import SwiftUI

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder?

    @objc func findFirstResponder(_: Any) {
        UIResponder._currentFirstResponder = self
    }
}
