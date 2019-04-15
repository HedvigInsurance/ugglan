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

    @available(iOS 11.0, *)
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }

        webView.stopLoading()

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        } else {
            let alert = Alert<Void>(
                title: String(key: .TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE),
                message: String(key: .TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE),
                actions: [
                    Alert.Action(
                        title: String(key: .TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION)
                    ) { () },
                ]
            )

            presentingViewController.present(alert)
        }
    }

    @available(iOS 11.0, *)
    func webView(_: WKWebView, stop _: WKURLSchemeTask) {
        // do nothing
    }

    init(_ presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
}

extension WKWebViewConfiguration {
    func addOpenBankIDBehaviour(_ presentingViewController: UIViewController) {
        if #available(iOS 11.0, *) {
            self.setURLSchemeHandler(
                OpenBankIdHandler(presentingViewController),
                forURLScheme: "bankid"
            )
        }
    }
}
