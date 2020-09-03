//
//  BankIDLoginNorway.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Apollo
import Flow
import Foundation
import hCore
import hGraphQL
import Presentation
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
        webView.backgroundColor = .secondaryBackground

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .primaryTintColor

        webView.addSubview(activityIndicator)

        activityIndicator.startAnimating()

        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }

        bag += webView.isLoadingSignal.animated(style: AnimationStyle.easeOut(duration: 0.5)) { loading in
            if loading {
                activityIndicator.alpha = 1
            } else {
                activityIndicator.alpha = 0
            }
        }

        viewController.view = webView

        bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
            guard let url = navigationAction.request.url else { return .allow }
            let urlString = String(describing: url)

            if urlString.contains("success") {
                return .cancel
            } else if urlString.contains("fail") {
                loadBankID()
                return .cancel
            }

            return .allow
        }

        bag += client.subscribe(subscription: GraphQL.BankIdAuthSubscriptionSubscription()).compactMap { $0.authStatus?.status }.filter(predicate: { status -> Bool in
            status == .success
        }).take(first: 1).onValue { _ in
            let appDelegate = UIApplication.shared.appDelegate

            if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
                appDelegate.registerFCMToken(fcmToken)
            }

            AnalyticsCoordinator().setUserId()

            let window = appDelegate.window
            appDelegate.bag += window.present(LoggedIn(), animated: true)
        }

        func loadBankID() {
            bag += client.perform(
                mutation: GraphQL.BankIdNorwayAuthMutation()
            ).valueSignal.compactMap { $0.norwegianBankIdAuth.redirectUrl }.onValue { urlString in
                guard let url = URL(string: urlString) else {
                    return
                }

                webView.load(URLRequest(url: url))
            }
        }

        loadBankID()

        return (viewController, Future { _ in
            bag
        })
    }
}
