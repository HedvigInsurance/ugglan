//
//  BankIDLoginNorway.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Foundation
import Presentation
import Flow
import Apollo
import UIKit
import WebKit

struct BankIDLoginNorway {
    @Inject var client: ApolloClient
}

extension BankIDLoginNorway: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = .primaryBackground
        
        viewController.view = webView
        
        bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
            guard let url = navigationAction.request.url else { return .allow }
            let urlString = String(describing: url)

            if urlString.contains("success") {
                let appDelegate = UIApplication.shared.appDelegate

                if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
                    appDelegate.registerFCMToken(fcmToken)
                }

                AnalyticsCoordinator().setUserId()

                let window = appDelegate.window
                bag += window.present(LoggedIn(), animated: true)
                
                return .cancel
            } else if urlString.contains("fail") {
                loadBankID()
                return .cancel
            }

            return .allow
        }
        
        func loadBankID() {
            bag += client.perform(
                mutation: BankIdNorwayAuthMutation()
            ).valueSignal.compactMap { $0.data?.norwegianBankIdAuth.redirectUrl }.onValue { urlString in
                guard let url = URL(string: urlString) else {
                    return
                }
                
                webView.load(URLRequest(url: url))
            }
        }
        
        loadBankID()
        
        return (viewController, Future { callback in
            return bag
        })
    }
}
