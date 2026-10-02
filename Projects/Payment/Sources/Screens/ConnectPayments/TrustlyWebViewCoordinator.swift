import Combine
import SafariServices
import UIKit
import WebKit

/// Fills the two gaps `TrustlyWKWebView` leaves: it exposes no loading state, and it declares
/// `WKUIDelegate` without implementing `createWebViewWith`, so `target="_blank"` links go nowhere.
///
/// Nothing here inspects URLs — success, error, abort and the BankID hand-off all arrive as
/// checkout events on the SDK's bridge. `navigationDelegate` is left to the SDK.
final class TrustlyWebViewCoordinator: NSObject, WKUIDelegate {
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()

    var isLoading: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }

    private weak var presentingViewController: UIViewController?
    private var observer: NSKeyValueObservation?

    init(webView: WKWebView, presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()

        webView.uiDelegate = self

        observer = webView.observe(
            \.isLoading,
            options: [.new],
            changeHandler: { [weak self] _, change in
                Task { @MainActor [weak self] in
                    self?.isLoadingSubject.send(change.newValue ?? false)
                }
            }
        )
    }

    func webView(
        _: WKWebView,
        createWebViewWith _: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures _: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            presentingViewController?.present(SFSafariViewController(url: url), animated: true)
        }
        return nil
    }
}
