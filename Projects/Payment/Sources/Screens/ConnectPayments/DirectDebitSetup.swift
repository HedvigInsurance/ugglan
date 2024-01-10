import Apollo
import Flow
import Foundation
import Presentation
import SafariServices
import UIKit
import WebKit
import hCore
import hGraphQL

struct DirectDebitSetup {
    @PresentableStore var paymentStore: PaymentStore
    @Inject var octopus: hOctopus

    let setupType: PaymentSetup.SetupType

    private func makeDismissButton() -> UIBarButtonItem {

        switch setupType {
        case .postOnboarding:
            return UIBarButtonItem(
                title: L10n.PayInIframePostSign.skipButton,
                style: UIColor.brandStyle(.navigationButton)
            )
        default:
            return UIBarButtonItem(
                title: L10n.PayInIframeInApp.cancelButton,
                style: UIColor.brandStyle(.navigationButton)
            )
        }
    }

    init(setupType: PaymentSetup.SetupType = .initial) { self.setupType = setupType }
}

extension DirectDebitSetup: Presentable {
    func materialize() -> (UIViewController, FiniteSignal<Bool>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.hidesBottomBarWhenPushed = true

        viewController.isModalInPresentation = true

        switch setupType {
        case .replacement: viewController.title = L10n.PayInIframeInApp.connectPayment
        case .postOnboarding, .initial, .preOnboarding: viewController.title = L10n.PayInIframePostSign.title
        }

        let dismissButton = makeDismissButton()

        let userContentController = WKUserContentController()

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webViewConfiguration.addOpenBankIDBehaviour(viewController)

        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.backgroundColor = .brand(.secondaryBackground())
        webView.isOpaque = false

        bag += webView.createWebViewWith.set { (_, _, navigationAction, _) -> WKWebView? in
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    viewController.present(
                        SFSafariViewController(url: url),
                        animated: true,
                        completion: nil
                    )
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
        activityIndicator.style = .large
        activityIndicator.color = .brand(.primaryText())

        webView.addSubview(activityIndicator)

        activityIndicator.startAnimating()

        activityIndicator.snp.makeConstraints { make in make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        let urlSignal = ReadWriteSignal<URL?>(nil)
        bag += webView.isLoadingSignal.animated(style: AnimationStyle.easeOut(duration: 0.5)) { loading in
            if loading { activityIndicator.alpha = 1 } else { activityIndicator.alpha = 0 }
        }
        let shouldDismissViewSignal = ReadWriteSignal<Bool>(false)
        let didFailToLoadWebViewSignal = ReadWriteSignal<Bool>(false)
        func presentAlert() {
            let alert = Alert(
                title: L10n.generalError,
                message: L10n.somethingWentWrong,
                tintColor: nil,
                actions: [
                    Alert.Action(title: L10n.generalRetry, style: UIAlertAction.Style.default) {
                        true
                    },
                    Alert.Action(
                        title: L10n.alertCancel,
                        style: UIAlertAction.Style.cancel
                    ) { false },
                ]
            )
            bag += viewController.present(alert)
                .onValue { shouldRetry in
                    if shouldRetry {
                        startRegistration()
                    } else {
                        shouldDismissViewSignal.value = true
                    }
                }

        }
        func startRegistration() {
            viewController.view = webView
            viewController.navigationItem.setLeftBarButton(dismissButton, animated: true)
            let mutation = OctopusGraphQL.RegisterDirectDebitMutation()
            bag += octopus.client.perform(mutation: mutation)
                .onValue({ data in
                    if let url = URL(string: data.registerDirectDebit2.url) {
                        let request = URLRequest(
                            url: url,
                            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                            timeoutInterval: 10
                        )
                        urlSignal.value = url
                        webView.load(request)
                    } else {
                        presentAlert()
                    }
                })
                .onError({ error in
                    presentAlert()
                })
        }

        bag += combineLatest(Signal(after: 5), webView.isLoadingSignal, urlSignal.future.resultSignal)
            .onValue { _, isLoading, url in
                if isLoading {
                    didFailToLoadWebViewSignal.value = true
                    if let url = url.value, let urlToOpen = url {
                        UIApplication.shared.open(urlToOpen)
                        didFailToLoadWebViewSignal.value = true
                    } else {
                        presentAlert()
                    }

                }
            }

        bag += combineLatest(
            didFailToLoadWebViewSignal.future.resultSignal,
            NotificationCenter.default.signal(forName: UIApplication.willEnterForegroundNotification)
        )
        .onValue { (didFailToLoad, _) in
            if didFailToLoad.value == true {
                shouldDismissViewSignal.value = true
            }
        }
        startRegistration()
        return (
            viewController,
            FiniteSignal { callback in
                bag +=
                    shouldDismissViewSignal
                    .filter(predicate: { $0 })
                    .onValue({ _ in
                        paymentStore.send(.fetchPaymentStatus)
                        callback(.value(true))
                    })

                bag += dismissButton.onValue {
                    var alert: Alert<Bool>

                    switch self.setupType {
                    case .initial, .preOnboarding:
                        alert = Alert<Bool>(
                            title: L10n.PayInIframeInAppCancelAlert.title,
                            message: L10n.PayInIframeInAppCancelAlert.body,
                            actions: [
                                Alert.Action(
                                    title: L10n.PayInIframeInAppCancelAlert
                                        .proceedButton
                                ) { true },
                                Alert.Action(
                                    title: L10n.PayInIframeInAppCancelAlert
                                        .dismissButton
                                ) { false },
                            ]
                        )
                    case .postOnboarding:
                        alert = Alert<Bool>(
                            title: L10n.PayInIframePostSignSkipAlert.title,
                            message: L10n.PayInIframePostSignSkipAlertDirectDebit.body,
                            actions: [
                                Alert.Action(
                                    title: L10n.PayInIframePostSignSkipAlert
                                        .proceedButton
                                ) { true },
                                Alert.Action(
                                    title: L10n.PayInIframePostSignSkipAlert
                                        .dismissButton
                                ) { false },
                            ]
                        )
                    case .replacement:
                        callback(.value(true))
                        return
                    }
                    bag += viewController.present(alert)
                        .onValue { shouldDismiss in
                            if shouldDismiss {
                                callback(.value(true))
                            }
                        }

                }

                func showResultScreen(type: DirectDebitResultType) {
                    viewController.navigationItem.setLeftBarButtonItems(nil, animated: true)

                    let containerView = UIView()
                    containerView.backgroundColor = .brand(.secondaryBackground())

                    let directDebitResult = DirectDebitResult(type: type)

                    switch type {
                    case .success:
                        paymentStore.send(.fetchPaymentStatus)
                    case .failure:
                        break
                    }

                    bag +=
                        containerView.add(directDebitResult) { view in
                            view.snp.makeConstraints { make in make.size.equalToSuperview()
                                make.edges.equalToSuperview()
                            }
                        }
                        .onValue { success in
                            paymentStore.send(.fetchPaymentStatus)
                            callback(.value(success))
                        }
                        .onError { _ in
                            bag += Signal(after: 0.5).onValue { _ in startRegistration() }
                        }

                    viewController.view = containerView
                }
                bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
                    guard let url = navigationAction.request.url else { return .allow }
                    let urlString = String(describing: url)

                    if urlString.contains("fail") || urlString.contains("success") {
                        showResultScreen(
                            type: urlString.contains("success")
                                ? .success(setupType: self.setupType)
                                : .failure(setupType: self.setupType)
                        )
                        return .cancel
                    }

                    return .allow
                }
                return DelayedDisposer(bag, delay: 1)
            }
        )
    }
}
