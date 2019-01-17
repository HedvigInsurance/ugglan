//
//  UIWebView+Signal.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIWebView: UIWebViewDelegate {
    private static var _didFinishLoadSignal: UInt8 = 0
    private static var _didFinishLoadCallbacker: UInt8 = 1

    private var didFinishLoadCallbacker: Callbacker<Void> {
        guard let value = objc_getAssociatedObject(
            self,
            &UIWebView._didFinishLoadCallbacker
        ) as? Callbacker<Void> else {
            let value = Callbacker<Void>()
            objc_setAssociatedObject(
                self,
                &UIWebView._didFinishLoadCallbacker,
                value,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return value
        }

        return value
    }

    var didFinishLoadSignal: Signal<Void> {
        delegate = self

        guard let value = objc_getAssociatedObject(
            self,
            &UIWebView._didFinishLoadSignal
        ) as? Signal<Void> else {
            let value = Signal<Void>(callbacker: didFinishLoadCallbacker)

            objc_setAssociatedObject(
                self,
                &UIWebView._didFinishLoadSignal,
                value,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )

            return value
        }

        return value
    }

    public func webViewDidFinishLoad(_: UIWebView) {
        didFinishLoadCallbacker.callAll()
    }
}
