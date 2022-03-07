import Flow
import Form
import Foundation
import UIKit

extension SubviewOrderable {
    /// appends view and removes from superview on disposal
    public func appendRemovable<V: UIView>(_ view: V) -> Disposable {
        orderedViews.append(view)
        return Disposer {
            view.removeFromSuperview()
        }
    }
}
