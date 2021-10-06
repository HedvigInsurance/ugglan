import Foundation
import UIKit

extension UIView {
    public static var outsideOfBoundsKey: UInt8 = 0

    /// This propery is set on the parent of the view that first clips the content you want to be touchable
    /// outside of the bounds
    public var allowTouchesOfViewsOutsideBounds: Bool {
        get {
            return objc_getAssociatedObject(self, &Self.outsideOfBoundsKey) as? Bool ?? false
        }
        set {
            UIView.swizzlePointInsideIfNeeded()
            subviews.forEach({ $0.allowTouchesOfViewsOutsideBounds = newValue })
            objc_setAssociatedObject(self, &Self.outsideOfBoundsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public func hasSubview(at point: CGPoint) -> Bool {
        if subviews.isEmpty {
            return self.bounds.contains(point)
        }
        return subviews.contains { subview -> Bool in
            let converted = self.convert(point, to: subview)
            return subview.hasSubview(at: converted)
        }
    }

    static private var hasSwizzled: Bool = false

    @objc public func _point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if allowTouchesOfViewsOutsideBounds {
            return _point(inside: point, with: event) || hasSubview(at: point)
        }
        return _point(inside: point, with: event)
    }

    static private func swizzlePointInsideIfNeeded() {
        guard !hasSwizzled else {
            return
        }
        guard let originalSelector = class_getInstanceMethod(self, #selector(point(inside:with:))),
            let swizzledSelector = class_getInstanceMethod(self, #selector(_point(inside:with:)))
        else {
            return
        }
        hasSwizzled = true
        method_exchangeImplementations(originalSelector, swizzledSelector)
    }
}
