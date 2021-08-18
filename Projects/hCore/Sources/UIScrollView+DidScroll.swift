import Flow
import Foundation
import UIKit

private var didScrollCallbackerKey = 0

extension UIScrollView: UIScrollViewDelegate {
    private var didScrollCallbacker: Callbacker<Void> {
        if let callbacker = objc_getAssociatedObject(self, &didScrollCallbackerKey) as? Callbacker<Void> {
            return callbacker
        }

        delegate = self

        let callbacker = Callbacker<Void>()

        objc_setAssociatedObject(self, &didScrollCallbackerKey, callbacker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return callbacker
    }

    public var didScrollSignal: Signal<Void> {
        didScrollCallbacker.providedSignal
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollCallbacker.callAll()
    }
}
