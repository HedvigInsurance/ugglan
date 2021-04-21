//
//  UIScrollView+DidScroll.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-04-21.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow

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
