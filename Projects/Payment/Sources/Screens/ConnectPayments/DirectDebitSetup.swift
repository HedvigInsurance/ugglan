import Apollo
import Combine
import Foundation
import PresentableStore
import SafariServices
import SwiftUI
import WebKit
import hCore
import hCoreUI

private class DirectDebitWebview: UIView {
    var paymentService = hPaymentService()
    @PresentableStore var paymentStore: PaymentStore
    private let resultSubject = PassthroughSubject<URL?, Never>()
    var cancellables = Set<AnyCancellable>()
    let vc = UIViewController()
    var webView = WKWebView()
    var webViewDelegate = WebViewDelegate(webView: .init())
    @Binding var showErrorAlert: Bool
    let router: NavigationRouter
    let onSuccess: (() -> Void)?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        showErrorAlert: Binding<Bool>,
        router: NavigationRouter,
        onSuccess: (() -> Void)?
    ) {
        _showErrorAlert = showErrorAlert
        self.router = router
        self.onSuccess = onSuccess
        super.init(frame: .zero)

        presentWebView()
        presentActivityIndicator()
        retryInBrowserFailedToLoad()
        checkForResult()

        Task {
            await startRegistration()
        }

        addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
    }

    private func presentWebView() {
        let userContentController = WKUserContentController()
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webViewConfiguration.addOpenBankIDBehaviour(vc)

        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.backgroundColor = .brand(.secondaryBackground())
        webView.isOpaque = false

        webViewDelegate = WebViewDelegate(webView: webView)
        webViewDelegate.actionPublished
            .sink { [weak self] navigationAction in
                if navigationAction.targetFrame == nil,
                    let url = navigationAction.request.url
                {
                    self?.vc.present(SFSafariViewController(url: url), animated: true)
                }
            }
            .store(in: &cancellables)

        userContentController.add(
            TrustlyWKScriptOpenURLScheme(webView: webView),
            name: TrustlyWKScriptOpenURLScheme.NAME
        )

        vc.view = webView
    }

    private func presentActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .brand(.primaryText())

        webView.addSubview(activityIndicator)

        activityIndicator.startAnimating()

        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }

        webViewDelegate.isLoading
            .sink { loading in
                activityIndicator.alpha = loading ? 1 : 0
            }
            .store(in: &cancellables)
    }

    private func retryInBrowserFailedToLoad() {
        let didFailToLoadWebViewSignal = CurrentValueSubject<Bool, Never>(false)
        let shouldDismissViewSignal = CurrentValueSubject<Bool, Never>(false)

        let publisherDelay = Timer.TimerPublisher(interval: 5.0, runLoop: .main, mode: .default).autoconnect()
        Publishers.CombineLatest3(publisherDelay, webViewDelegate.isLoading, resultSubject)
            .sink { [weak self] _, isLoading, url in
                publisherDelay.upstream.connect().cancel()
                if isLoading {
                    didFailToLoadWebViewSignal.send(true)
                    if let url {
                        Dependencies.urlOpener.open(url)
                    } else {
                        self?.showErrorAlert = true
                    }
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(
            didFailToLoadWebViewSignal,
            NotificationCenter.Publisher(center: .default, name: UIApplication.willEnterForegroundNotification)
        )
        .sink { didFail, _ in
            if didFail {
                shouldDismissViewSignal.send(true)
            }
        }
        .store(in: &cancellables)

        shouldDismissViewSignal
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.paymentStore.send(.fetchPaymentStatus)
                self?.router.dismiss()
            }
            .store(in: &cancellables)
    }

    private func checkForResult() {
        webViewDelegate.decidePolicyForNavigationAction
            .receive(on: RunLoop.main)
            .sink { [weak self] success in
                self?.showResultScreen(type: success ? .success : .failure)
            }
            .store(in: &cancellables)
    }

    private func showResultScreen(type: DirectDebitResultType) {
        vc.navigationItem.setLeftBarButtonItems(nil, animated: true)
        let directDebitResult = DirectDebitResult(
            type: type,
            action: { [weak self, weak router] in
                router?.dismiss()
            }
        )

        if type == .success {
            paymentStore.send(.fetchPaymentStatus)
        }

        let debitResultHostingView = UIHostingController(rootView: directDebitResult)
        let backgroundView = UIView()
        let scheme = UITraitCollection.current.userInterfaceStyle == .light ? ColorScheme.light : .dark
        backgroundView.backgroundColor = hBackgroundColor.primary.colorFor(scheme, .base).color.uiColor()
        addSubview(backgroundView)
        addSubview(debitResultHostingView.view)

        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(-100)
            make.top.equalToSuperview().inset(-100)
        }

        debitResultHostingView.view.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {}
        )
    }

    private func startRegistration() async {
        vc.view = webView
        do {
            let result = try await paymentService.setupPaymentMethod(
                .trustly
            )
            guard let urlString = result.url, let url = URL(string: urlString) else {
                self.showErrorAlert = true
                return
            }
            let request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 10
            )
            resultSubject.send(url)
            webView.load(request)
        } catch {
            self.showErrorAlert = true
        }
    }
}

struct DirectDebitSetupRepresentable: UIViewRepresentable {
    @Binding var showErrorAlert: Bool
    let router: NavigationRouter
    let onSuccess: (() -> Void)?

    func makeUIView(context _: Context) -> some UIView {
        DirectDebitWebview(
            showErrorAlert: $showErrorAlert,
            router: router,
            onSuccess: onSuccess
        )
    }

    func updateUIView(_: UIViewType, context _: Context) {}
}

public struct DirectDebitSetup: View {
    enum AlertType: Identifiable {
        case cancel
        case error

        var id: Self { self }
    }

    @State var activeAlert: AlertType?
    @State var showNotSupported: Bool = false

    @StateObject private var ownedRouter = NavigationRouter()
    @ObservedObject private var externalRouter: NavigationRouter
    private var hasExternalRouter: Bool
    var router: NavigationRouter { hasExternalRouter ? externalRouter : ownedRouter }
    let setupType: SetupType
    let onSuccess: (() -> Void)?

    public init(
        setupType: SetupType? = nil,
        router: NavigationRouter? = nil,
        onSuccess: (() -> Void)? = nil
    ) {
        let finalSetupType: SetupType = {
            if let setupType {
                return setupType
            }
            let store: PaymentStore = globalPresentableStoreContainer.get()
            let hasAlreadyConnected = [PayinMethodStatus.active, PayinMethodStatus.pending]
                .contains(store.state.paymentStatusData?.status ?? .active)
            return hasAlreadyConnected ? .replacement : .initial
        }()
        showNotSupported = !Dependencies.featureFlags().isConnectPaymentEnabled
        self.setupType = finalSetupType
        self.onSuccess = onSuccess
        self.hasExternalRouter = router != nil
        self._externalRouter = ObservedObject(wrappedValue: router ?? NavigationRouter())
    }

    public var body: some View {
        Group {
            if showNotSupported {
                GenericErrorView(
                    title: L10n.moveintentGenericError,
                    description: nil,
                    formPosition: .center
                )
                .hStateViewButtonConfig(
                    .init(
                        actionButtonAttachedToBottom: .init(
                            buttonTitle: L10n.openChat,
                            buttonAction: { [weak router] in
                                router?.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    NotificationCenter.default.post(
                                        name: .openChat,
                                        object: ChatType.newConversation
                                    )
                                }
                            }
                        ),
                        dismissButton: .init(
                            buttonAction: { [weak router] in
                                router?.dismiss()
                            }
                        )
                    )
                )
            } else {
                DirectDebitSetupRepresentable(showErrorAlert: showErrorAlertBinding, router: router) { [onSuccess] in
                    onSuccess?()
                }
                .alert(item: $activeAlert) { alertType in
                    switch alertType {
                    case .cancel:
                        cancelAlert()
                    case .error:
                        errorAlert()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                if !showNotSupported {
                    dismissButton
                }
            }
        }
        .navigationTitle(
            setupType == .replacement
                ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
        )
        .embededInNavigation(router: router, tracking: self)
    }

    private var showErrorAlertBinding: Binding<Bool> {
        Binding(
            get: { activeAlert == .error },
            set: { if $0 { activeAlert = .error } }
        )
    }

    private var dismissButton: some View {
        hText(
            setupType == .postOnboarding ? L10n.PayInIframePostSign.skipButton : L10n.generalCancelButton,
            style: .heading1
        )
        .padding(.horizontal, .padding4)
        .fixedSize()
        .onTapGesture { [weak router] in
            if showNotSupported {
                router?.dismiss()
            } else {
                activeAlert = .cancel
            }
        }
        .accessibilityAddTraits(.isButton)
    }

    private func cancelAlert() -> SwiftUI.Alert {
        Alert(
            title: Text(L10n.PayInIframeInAppCancelAlert.title),
            message: Text(L10n.PayInIframeInAppCancelAlert.body),
            primaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.proceedButton)) { [weak router] in
                router?.dismiss()
            },
            secondaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.dismissButton))
        )
    }

    private func errorAlert() -> SwiftUI.Alert {
        Alert(
            title: Text(L10n.generalError),
            message: Text(L10n.somethingWentWrong),
            primaryButton: .default(Text(L10n.generalRetry)),
            secondaryButton: .cancel(Text(L10n.alertCancel)) { [weak router] in
                router?.dismiss()
            }
        )
    }
}

public enum SetupType: Equatable {
    case initial
    case preOnboarding(monthlyNetCost: MonetaryAmount?)
    case replacement, postOnboarding
}

extension DirectDebitSetup: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: DirectDebitSetup.self)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    return DirectDebitSetup(setupType: .initial)
}
