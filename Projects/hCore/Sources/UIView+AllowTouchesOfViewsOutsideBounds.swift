//
//  UIView+AllowTouchesOfViewsOutsideBounds.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-04-20.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    private struct ExtendedTouchAssociatedKey {
        static var outsideOfBounds = "viewExtensionAllowTouchesOutsideOfBounds"
    }

    /// This propery is set on the parent of the view that first clips the content you want to be touchable
    /// outside of the bounds
    var allowTouchesOfViewsOutsideBounds:Bool {
        get {
            return objc_getAssociatedObject(self, &ExtendedTouchAssociatedKey.outsideOfBounds) as? Bool ?? false
        }
        set {
            UIView.swizzlePointInsideIfNeeded()
            subviews.forEach({$0.allowTouchesOfViewsOutsideBounds = newValue})
            objc_setAssociatedObject(self, &ExtendedTouchAssociatedKey.outsideOfBounds, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func hasSubview(at point:CGPoint) -> Bool {
        if subviews.count == 0 {
            return self.bounds.contains(point)
        }
        return subviews.contains(where: { (subview) -> Bool in
            let converted = self.convert(point, to: subview)
            return subview.hasSubview(at: converted)
        })

    }

    static private var swizzledMethods:Bool = false

    @objc func _point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        if allowTouchesOfViewsOutsideBounds {
            return  _point(inside:point,with:event) || hasSubview(at: point)
        }
        return _point(inside:point,with:event)
    }

    static private func swizzlePointInsideIfNeeded() {
        if swizzledMethods {
            return
        }
        swizzledMethods = true
        guard let originalSelector = class_getInstanceMethod(self, #selector(point(inside:with:))),
              let swizzledSelector = class_getInstanceMethod(self, #selector(_point(inside:with:))) else {
            return
        }
        method_exchangeImplementations(originalSelector, swizzledSelector)
    }
}
