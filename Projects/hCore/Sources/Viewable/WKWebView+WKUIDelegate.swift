import Combine
import WebKit

public class WebViewDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    public let actionPublished = PassthroughSubject<WKNavigationAction, Never>()
    public let challengeReceive = PassthroughSubject<URLAuthenticationChallenge, Never>()
    public let isLoading = PassthroughSubject<Bool, Never>()
    public let result = PassthroughSubject<URL?, Never>()
    public let error = PassthroughSubject<Error, Never>()
    var observer: NSKeyValueObservation?
    public let decidePolicyForNavigationAction = PassthroughSubject<Bool, Never>()

    public init(
        webView: WKWebView
    ) {
        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self

        observer = webView.observe(
            \.isLoading,
            options: [.new],
            changeHandler: { _, change in
                self.isLoading.send(change.newValue ?? false)
            }
        )
    }

    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        self.challengeReceive.send(challenge)

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.error.send(error)
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        self.actionPublished.send(navigationAction)

        guard let url = navigationAction.request.url else { return .allow }
        let urlString = String(describing: url)

        if urlString.contains("fail") || urlString.contains("success") {
            self.decidePolicyForNavigationAction.send(urlString.contains("success") ? true : false)
            return .cancel
        }

        return .allow
    }

}
