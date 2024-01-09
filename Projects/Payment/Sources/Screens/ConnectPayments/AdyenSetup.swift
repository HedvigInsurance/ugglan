import Apollo
import Flow
import Foundation
import Presentation
import SafariServices
import UIKit
import WebKit
import hCore
import hCoreUI
import hGraphQL

struct AdyenSetup {
    @PresentableStore var paymentStore: PaymentStore
    @Inject var adyenService: AdyenService

    let setupType: PaymentSetup.SetupType

    private func makeDismissButton() -> UIBarButtonItem {

        switch setupType {
        case .postOnboarding:
            return UIBarButtonItem(
                title: L10n.PayInIframePostSign.skipButton,
                style: UIColor.brandStyle(.adyenWebViewText)
            )
        default:
            return UIBarButtonItem(
                title: L10n.PayInIframeInApp.cancelButton,
                style: UIColor.brandStyle(.adyenWebViewText)
            )
        }
    }

    init(setupType: PaymentSetup.SetupType = .initial) { self.setupType = setupType }
}

extension AdyenSetup: Presentable {
    func materialize() -> (UIViewController, FiniteSignal<Bool>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        configureNavigation(for: viewController)
        viewController.hidesBottomBarWhenPushed = true
        viewController.isModalInPresentation = true

        switch setupType {
        case .replacement:
            viewController.title = L10n.PayInIframeInApp.connectPayment
        case .postOnboarding, .initial, .preOnboarding:
            viewController.title = L10n.PayInIframePostSign.title
        }

        let dismissButton = makeDismissButton()
        let webViewConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.backgroundColor = .brand(.adyenWebViewBg)
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

            Task {
                do {
                    let url = try await adyenService.getAdyenUrl()
                    urlSignal.value = url
                    let request = URLRequest(
                        url: url,
                        cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                        timeoutInterval: 10
                    )
                    await webView.load(request)
                } catch {
                    presentAlert()
                }

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
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        store.send(.fetchPaymentStatus)
                        callback(.value(true))
                        return
                    }
                    bag += viewController.present(alert)
                        .onValue { shouldDismiss in
                            let store: PaymentStore = globalPresentableStoreContainer.get()
                            store.send(.fetchPaymentStatus)
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
                        break
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

    func configureNavigation(for vc: UIViewController) {
        let appearance = UINavigationBar.appearance().standardAppearance.copy()
        appearance.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.brand(.adyenWebViewText)
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.brand(.adyenWebViewBg)
        appearance.shadowColor = nil
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        vc.navigationItem.standardAppearance = appearance
        vc.navigationItem.scrollEdgeAppearance = appearance
        vc.navigationItem.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            vc.navigationItem.compactScrollEdgeAppearance = appearance
        }
    }
}
