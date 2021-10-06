import Flow
import Foundation
import WebKit

extension WKWebView: WKUIDelegate {
    private static var _createWebViewWith: UInt8 = 0

    public typealias CreateWebViewWithDelegate = Delegate<
        (WKWebView, WKWebViewConfiguration, WKNavigationAction, WKWindowFeatures), WKWebView?
    >

    public var createWebViewWith: CreateWebViewWithDelegate {
        if let delegate = objc_getAssociatedObject(self, &WKWebView._createWebViewWith)
            as? CreateWebViewWithDelegate
        {
            return delegate
        }

        let delegate = CreateWebViewWithDelegate()

        objc_setAssociatedObject(
            self,
            &WKWebView._createWebViewWith,
            delegate,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        uiDelegate = self

        return delegate
    }

    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let delegateWebView = createWebViewWith.call(
            (webView, configuration, navigationAction, windowFeatures)
        ) {
            return delegateWebView
        }

        return nil
    }
}
