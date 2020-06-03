//
//  DirectDebitSetup.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-24.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import hCore
import Presentation
import SafariServices
import UIKit
import WebKit

struct DirectDebitSetup {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let setupType: PaymentSetup.SetupType
    let applicationWillTerminateSignal: Signal<Void>

    private func makeDismissButton() -> UIBarButtonItem {
        switch setupType {
        case .postOnboarding:
            return UIBarButtonItem(
                title: L10n.trustlySkipButton,
                style: .navigationBarButtonSkip
            )
        default:
            return UIBarButtonItem(
                title: L10n.directDebitDismissButton,
                style: .navigationBarButton
            )
        }
    }

    init(
        setupType: PaymentSetup.SetupType = .initial,
        applicationWillTerminateSignal: Signal<Void> = UIApplication.shared.appDelegate.applicationWillTerminateSignal
    ) {
        self.setupType = setupType
        self.applicationWillTerminateSignal = applicationWillTerminateSignal
    }
}

extension DirectDebitSetup: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.hidesBottomBarWhenPushed = true

        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }

        switch setupType {
        case .initial:
            viewController.title = L10n.directDebitSetupScreenTitle
        case .replacement:
            viewController.title = L10n.directDebitSetupChangeScreenTitle
        case .postOnboarding:
            viewController.title = L10n.directDebitSetupScreenTitle
        }

        let dismissButton = makeDismissButton()

        let userContentController = WKUserContentController()

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webViewConfiguration.addOpenBankIDBehaviour(viewController)

        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.backgroundColor = .offWhite
        webView.isOpaque = false

        bag += webView.createWebViewWith.set { (_, _, navigationAction, _) -> WKWebView? in
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    viewController.present(SFSafariViewController(url: url), animated: true, completion: nil)
                }
            }

            return nil
        }

        userContentController.add(
            TrustlyWKScriptOpenURLScheme(webView: webView),
            name: TrustlyWKScriptOpenURLScheme.NAME
        )

        viewController.view = webView

        bag += webView.didReceiveAuthenticationChallenge.set { _, challenge in
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)

                return (.useCredential, cred)
            }

            return (.performDefaultHandling, nil)
        }

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

        func startRegistration() {
            viewController.view = webView
            viewController.navigationItem.setLeftBarButton(dismissButton, animated: true)

            bag += client.perform(mutation: StartDirectDebitRegistrationMutation())
                .valueSignal
                .compactMap { $0.data?.startDirectDebitRegistration }
                .onValue { startDirectDebitRegistration in
                    webView.load(URLRequest(url: URL(string: startDirectDebitRegistration)!))
                }
        }

        startRegistration()

        return (viewController, Future { completion in
            bag += dismissButton.onValue {
                let alert = Alert<Bool>.init(
                    title: L10n.directDebitDismissAlertTitle,
                    message: L10n.directDebitDismissAlertMessage,
                    actions: [
                        Alert.Action(title: L10n.directDebitDismissAlertConfirmAction) {
                            true
                        },
                        Alert.Action(title: L10n.directDebitDismissAlertCancelAction) {
                            false
                        },
                    ]
                )

                bag += viewController.present(alert).onValue { shouldDismiss in
                    if shouldDismiss {
                        self.client.perform(mutation: CancelDirectDebitRequestMutation()).onValue { _ in }
                        completion(.success)
                    }
                }
            }

            func showResultScreen(type: DirectDebitResultType) {
                viewController.navigationItem.setLeftBarButtonItems(nil, animated: true)

                let containerView = UIView()
                containerView.backgroundColor = .primaryBackground

                let directDebitResult = DirectDebitResult(
                    type: type
                )

                switch type {
                case .success:
                    self.store.update(query: MyPaymentQuery(), updater: { (data: inout MyPaymentQuery.Data) in
                        data.payinMethodStatus = .pending
                    })
                    ClearDirectDebitStatus.clear()
                case .failure:
                    break
                }

                bag += containerView.add(directDebitResult) { view in
                    view.snp.makeConstraints { make in
                        make.size.equalToSuperview()
                        make.edges.equalToSuperview()
                    }
                }.onValue {
                    completion(.success)
                }.onError { _ in
                    bag += Signal(after: 0.5).onValue { _ in
                        startRegistration()
                    }
                }

                viewController.view = containerView
            }

            bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
                guard let url = navigationAction.request.url else { return .allow }
                let urlString = String(describing: url)

                if urlString.contains("fail") || urlString.contains("success") {
                    showResultScreen(
                        type: urlString.contains("success") ?
                            .success(setupType: self.setupType) :
                            .failure(setupType: self.setupType)
                    )
                    return .cancel
                }

                return .allow
            }

            // if user is closing app in the middle of process make sure to inform backend
            bag += self.applicationWillTerminateSignal.onValue {
                self.client.perform(mutation: CancelDirectDebitRequestMutation()).onValue { _ in }
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
