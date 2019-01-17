//
//  UIWebView+Delegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIWebView: UIWebViewDelegate {
    private static var _didFinishLoadDelegate: UInt8 = 0

    var didFinishLoadDelegate: Delegate<UIWebView, Void> {
        get {
            delegate = self

            guard let value = objc_getAssociatedObject(
                self,
                &UIWebView._didFinishLoadDelegate
            ) as? Delegate<UIWebView, Void> else {
                let value = Delegate<UIWebView, Void>()
                self.didFinishLoadDelegate = value
                return value
            }

            return value
        }
        set(newValue) {
            delegate = self

            objc_setAssociatedObject(
                self,
                &UIWebView._didFinishLoadDelegate,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        didFinishLoadDelegate.call(webView)
    }
}
