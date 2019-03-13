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
import Presentation
import WebKit

struct DirectDebitSetup {
    let client: ApolloClient
    let store: ApolloStore
    let setupType: SetupType
    let applicationWillTerminateSignal: Signal<Void>

    enum SetupType {
        case initial, replacement
    }

    init(
        setupType: SetupType = .initial,
        client: ApolloClient = HedvigApolloClient.shared.client!,
        store: ApolloStore = HedvigApolloClient.shared.store!,
        applicationWillTerminateSignal: Signal<Void> = UIApplication.shared.appDelegate.applicationWillTerminateSignal
    ) {
        self.setupType = setupType
        self.client = client
        self.store = store
        self.applicationWillTerminateSignal = applicationWillTerminateSignal
    }
}

extension DirectDebitSetup: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.hidesBottomBarWhenPushed = true
        viewController.title = setupType == .initial ? String(.DIRECT_DEBIT_SETUP_SCREEN_TITLE) :
            String(.DIRECT_DEBIT_SETUP_CHANGE_SCREEN_TITLE)

        let dismissButton = UIBarButtonItem(
            title: String(.DIRECT_DEBIT_DISMISS_BUTTON),
            style: .navigationBarButton
        )
        bag += viewController.installDismissBarItem(dismissButton)
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.addOpenBankIDBehaviour(viewController)
        
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.backgroundColor = .offWhite
        webView.isOpaque = false

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
        activityIndicator.color = .purple

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

        bag += client.perform(mutation: StartDirectDebitRegistrationMutation())
            .valueSignal
            .compactMap { $0.data?.startDirectDebitRegistration }
            .onValue { startDirectDebitRegistration in
                webView.load(URLRequest(url: URL(string: startDirectDebitRegistration)!))
            }

        return (viewController, Future { completion in
            bag += dismissButton.onValue {
                let alert = Alert<Bool>.init(
                    title: String(.DIRECT_DEBIT_DISMISS_ALERT_TITLE),
                    message: String(.DIRECT_DEBIT_DISMISS_ALERT_MESSAGE),
                    actions: [
                        Alert.Action(title: String(.DIRECT_DEBIT_DISMISS_ALERT_CONFIRM_ACTION)) {
                            true
                        },
                        Alert.Action(title: String(.DIRECT_DEBIT_DISMISS_ALERT_CANCEL_ACTION)) {
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
                containerView.backgroundColor = .offWhite

                let directDebitResult = DirectDebitResult(
                    type: type
                )

                if type == .success {
                    self.store.update(query: MyPaymentQuery(), updater: { (data: inout MyPaymentQuery.Data) in
                        data.directDebitStatus = .pending
                    })

                    if objc_getClass("ReactNativeNavigation") != nil {
                        let bridge = ReactNativeNavigation.getBridge()
                        let nativeRouting = bridge?.module(forName: "NativeRouting") as! NativeRouting

                        nativeRouting.sendClearDirectDebitStatus()
                    }
                }

                bag += containerView.add(directDebitResult) { view in
                    view.snp.makeConstraints({ make in
                        make.size.equalToSuperview()
                        make.edges.equalToSuperview()
                    })
                }.onValue {
                    completion(.success)
                }

                viewController.view = containerView
            }
            
            bag += webView.decidePolicyForNavigationAction.set({ _, navigationAction in
                guard let url = navigationAction.request.url else { return .allow }
                let urlString = String(describing: url)

                if urlString.contains("fail") || urlString.contains("success") {
                    showResultScreen(type: urlString.contains("success") ? .success : .failure)
                    return .cancel
                }

                return .allow
            })
            
            // if user is closing app in the middle of process make sure to inform backend
            bag += self.applicationWillTerminateSignal.onValue {
                self.client.perform(mutation: CancelDirectDebitRequestMutation()).onValue { _ in }
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
