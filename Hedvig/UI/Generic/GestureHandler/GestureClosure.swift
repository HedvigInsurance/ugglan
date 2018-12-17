//
//  GestureClosure.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-17.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import UIKit

private var handlerKey: UInt8 = 0

internal extension UIGestureRecognizer {
    internal func setHandler<T: UIGestureRecognizer>(_ instance: T, handler: ClosureHandler<T>) {
        objc_setAssociatedObject(self, &handlerKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        handler.control = instance
    }

    internal func handler<T>() -> ClosureHandler<T> {
        return objc_getAssociatedObject(self, &handlerKey) as? ClosureHandler ?? ClosureHandler<T>(handler: { _ in

        })
    }
}
