import Combine
import WebKit

public class WebViewDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    private let actionPublishedSubject = PassthroughSubject<WKNavigationAction, Never>()
    private let challengeReceiveSubject = PassthroughSubject<URLAuthenticationChallenge, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()

    public var actionPublished: AnyPublisher<WKNavigationAction, Never> {
        return actionPublishedSubject.eraseToAnyPublisher()
    }
    public var challengeReceive: AnyPublisher<URLAuthenticationChallenge, Never> {
        return challengeReceiveSubject.eraseToAnyPublisher()
    }
    public var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    public var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

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
                self.isLoadingSubject.send(change.newValue ?? false)
            }
        )
    }

    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        self.challengeReceiveSubject.send(challenge)

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.errorSubject.send(error)
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        self.actionPublishedSubject.send(navigationAction)

        guard let url = navigationAction.request.url else { return .allow }
        let urlString = String(describing: url)

        if urlString.contains("fail") || urlString.contains("success") {
            self.decidePolicyForNavigationAction.send(urlString.contains("success") ? true : false)
            return .cancel
        }

        return .allow
    }

}
