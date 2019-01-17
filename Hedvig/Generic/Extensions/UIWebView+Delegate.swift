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
    private static var _didFinishLoadDelegate = [String: Delegate<UIWebView, Void>]()

    var didFinishLoadDelegate: Delegate<UIWebView, Void> {
        get {
            self.delegate = self
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))

            if let delegate = UIWebView._didFinishLoadDelegate[tmpAddress] {
                return delegate
            }

            let delegate = Delegate<UIWebView, Void>()
            UIWebView._didFinishLoadDelegate[tmpAddress] = delegate

            return delegate
        }
        set(newValue) {
            delegate = self
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIWebView._didFinishLoadDelegate[tmpAddress] = newValue
        }
    }

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        didFinishLoadDelegate.call(webView)
    }
}
