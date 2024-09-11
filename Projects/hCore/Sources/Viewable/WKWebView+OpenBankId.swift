import Foundation
import PresentableStore
import UIKit
import WebKit

class OpenBankIdHandler: NSObject, WKURLSchemeHandler {
    let presentingViewController: UIViewController

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }

        webView.stopLoading()

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(
                title: L10n.trustlyMissingBankIdAppAlertTitle,
                message: L10n.trustlyMissingBankIdAppAlertMessage,
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: L10n.trustlyMissingBankIdAppAlertAction, style: .default)
            alert.addAction(action)
            presentingViewController.present(alert, animated: true)
        }
    }

    func webView(_: WKWebView, stop _: WKURLSchemeTask) {
        // do nothing
    }

    init(_ presentingViewController: UIViewController) { self.presentingViewController = presentingViewController }
}

extension WKWebViewConfiguration {
    public func addOpenBankIDBehaviour(_ presentingViewController: UIViewController) {
        setURLSchemeHandler(OpenBankIdHandler(presentingViewController), forURLScheme: "bankid")
    }
}
