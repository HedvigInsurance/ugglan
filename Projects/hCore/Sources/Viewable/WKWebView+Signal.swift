import Flow
import Foundation
import WebKit

extension WKWebView: WKNavigationDelegate {
    private static var _didReceiveAuthenticationChallenge: UInt8 = 0
    private static var _decidePolicyForNavigationAction: UInt8 = 1

    public typealias DidReceiveAuthenticationChallengeDelegate = Delegate<
        (WKWebView, URLAuthenticationChallenge), (URLSession.AuthChallengeDisposition, URLCredential?)
    >

    public var didReceiveAuthenticationChallenge: DidReceiveAuthenticationChallengeDelegate {
        if let delegate = objc_getAssociatedObject(self, &WKWebView._didReceiveAuthenticationChallenge)
            as? DidReceiveAuthenticationChallengeDelegate
        {
            return delegate
        }

        let delegate = DidReceiveAuthenticationChallengeDelegate()

        objc_setAssociatedObject(
            self,
            &WKWebView._didReceiveAuthenticationChallenge,
            delegate,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        navigationDelegate = self

        return delegate
    }

    public typealias DecidePolicyForNavigationActionDelegate = Delegate<
        (WKWebView, WKNavigationAction), WKNavigationActionPolicy
    >

    public var decidePolicyForNavigationAction: DecidePolicyForNavigationActionDelegate {
        if let delegate = objc_getAssociatedObject(self, &WKWebView._decidePolicyForNavigationAction)
            as? DecidePolicyForNavigationActionDelegate
        {
            return delegate
        }

        let delegate = DecidePolicyForNavigationActionDelegate()

        objc_setAssociatedObject(
            self,
            &WKWebView._decidePolicyForNavigationAction,
            delegate,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        navigationDelegate = self

        return delegate
    }

    public var isLoadingSignal: Signal<Bool> {
        Signal { callback in
            var observer: NSKeyValueObservation? = self.observe(
                \.isLoading,
                options: [.new],
                changeHandler: { _, change in callback(change.newValue ?? false) }
            )

            return Disposer {
                observer?.invalidate()
                observer = nil
            }
        }
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let result = decidePolicyForNavigationAction.call((webView, navigationAction))

        if let result = result { decisionHandler(result) } else { decisionHandler(.allow) }
    }

    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let result = didReceiveAuthenticationChallenge.call((webView, challenge))

        if let (disposition, credential) = result {
            completionHandler(disposition, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
