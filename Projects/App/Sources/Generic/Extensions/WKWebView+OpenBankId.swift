//
//  WKWebView+OpenBankId.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-27.
//

import Foundation
import Presentation
import WebKit

class OpenBankIdHandler: NSObject, WKURLSchemeHandler {
    let presentingViewController: UIViewController

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }

        webView.stopLoading()

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = Alert<Void>(
                title: L10n.trustlyMissingBankIdAppAlertTitle,
                message: L10n.trustlyMissingBankIdAppAlertMessage,
                actions: [
                    Alert.Action(
                        title: L10n.trustlyMissingBankIdAppAlertAction
                    ) { () },
                ]
            )

            presentingViewController.present(alert)
        }
    }

    func webView(_: WKWebView, stop _: WKURLSchemeTask) {
        // do nothing
    }

    init(_ presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
}

extension WKWebViewConfiguration {
    func addOpenBankIDBehaviour(_ presentingViewController: UIViewController) {
        setURLSchemeHandler(
            OpenBankIdHandler(presentingViewController),
            forURLScheme: "bankid"
        )
    }
}
