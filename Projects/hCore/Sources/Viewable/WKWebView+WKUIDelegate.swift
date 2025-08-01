@preconcurrency import Combine
@preconcurrency import WebKit

public class WebViewDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    private let actionPublishedSubject = PassthroughSubject<WKNavigationAction, Never>()
    private let challengeReceiveSubject = PassthroughSubject<URLAuthenticationChallenge, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()

    public var actionPublished: AnyPublisher<WKNavigationAction, Never> {
        actionPublishedSubject.eraseToAnyPublisher()
    }

    public var challengeReceive: AnyPublisher<URLAuthenticationChallenge, Never> {
        challengeReceiveSubject.eraseToAnyPublisher()
    }

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public var error: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
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
                Task { @MainActor in
                    self.isLoadingSubject.send(change.newValue ?? false)
                }
            }
        )
    }

    public func webView(
        _: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        challengeReceiveSubject.send(challenge)

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        errorSubject.send(error)
    }

    public func webView(
        _: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        actionPublishedSubject.send(navigationAction)

        guard let url = navigationAction.request.url else { return .allow }
        let urlString = String(describing: url)

        if urlString.contains("fail") || urlString.contains("success") {
            decidePolicyForNavigationAction.send(urlString.contains("success") ? true : false)
            return .cancel
        }

        return .allow
    }
}
