import Apollo
import Combine
import Foundation
import hCore
import hCoreUI
import PresentableStore
import SafariServices
import SwiftUI
import WebKit

private class DirectDebitWebview: UIView {
    var paymentService = hPaymentService()
    @PresentableStore var paymentStore: PaymentStore
    private let resultSubject = PassthroughSubject<URL?, Never>()
    var cancellables = Set<AnyCancellable>()
    let setupType: SetupType
    let vc = UIViewController()
    var webView = WKWebView()
    var webViewDelgate = WebViewDelegate(webView: .init())
    @Binding var showErrorAlert: Bool
    let router: Router

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        setupType: SetupType,
        showErrorAlert: Binding<Bool>,
        router: Router
    ) {
        self.setupType = setupType
        _showErrorAlert = showErrorAlert
        self.router = router
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

        webViewDelgate = WebViewDelegate(webView: webView)
        webViewDelgate.actionPublished
            .sink { _ in
            } receiveValue: { [weak self] navigationAction in
                if navigationAction.targetFrame == nil {
                    if let url = navigationAction.request.url {
                        self?.vc
                            .present(
                                SFSafariViewController(url: url),
                                animated: true,
                                completion: nil
                            )
                    }
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

        webViewDelgate.isLoading
            .sink { _ in
            } receiveValue: { loading in
                if loading { activityIndicator.alpha = 1 } else { activityIndicator.alpha = 0 }
            }
            .store(in: &cancellables)

        webViewDelgate.isLoading
            .sink { _ in
            } receiveValue: { loading in
                if loading { activityIndicator.alpha = 1 } else { activityIndicator.alpha = 0 }
            }
            .store(in: &cancellables)
    }

    private func retryInBrowserFailedToLoad() {
        let didFailToLoadWebViewSignal = CurrentValueSubject<Bool, Never>(false)
        let shouldDismissViewSignal = CurrentValueSubject<Bool, Never>(false)

        let publisherDelay = Timer.TimerPublisher(interval: 5.0, runLoop: .main, mode: .default).autoconnect()
        Publishers.CombineLatest3(publisherDelay, webViewDelgate.isLoading, resultSubject)
            .sink { _ in
            } receiveValue: { [weak self] _, isLoading, URL in
                publisherDelay.upstream.connect().cancel()
                if isLoading {
                    didFailToLoadWebViewSignal.send(true)
                    if let url = URL {
                        Dependencies.urlOpener.open(url)
                        didFailToLoadWebViewSignal.send(true)
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
        .sink { _ in
        } receiveValue: { didFail, _ in
            if didFail {
                shouldDismissViewSignal.send(true)
            }
        }
        .store(in: &cancellables)

        shouldDismissViewSignal
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }) { [weak self] _ in
                self?.paymentStore.send(.fetchPaymentStatus)
                self?.router.dismiss()
            }
            .store(in: &cancellables)
    }

    private func checkForResult() {
        webViewDelgate.decidePolicyForNavigationAction
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] success in
                guard let self = self else {
                    return
                }
                self.showResultScreen(
                    type: success
                        ? .success
                        : .failure
                )
            }
            .store(in: &cancellables)
    }

    private func showResultScreen(type: DirectDebitResultType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            vc.navigationItem.setLeftBarButtonItems(nil, animated: true)

            let directDebitResult = DirectDebitResult(
                type: type,
                retry: {
                    self.checkForResult()
                }
            )

            switch type {
            case .success:
                paymentStore.send(.fetchPaymentStatus)
            case .failure:
                break
            }
            let debitResultHostingView = UIHostingController(rootView: directDebitResult)
            let backgrondView = UIView()
            let schema = UITraitCollection.current.userInterfaceStyle == .light ? ColorScheme.light : .dark
            backgrondView.backgroundColor = hBackgroundColor.primary.colorFor(schema, .base).color.uiColor()
            self.addSubview(backgrondView)
            self.addSubview(debitResultHostingView.view)
            backgrondView.snp.makeConstraints { make in
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
    }

    private func startRegistration() async {
        vc.view = webView
        Task {
            do {
                let url = try await paymentService.getConnectPaymentUrl()
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
}

struct DirectDebitSetupRepresentable: UIViewRepresentable {
    let setupType: SetupType
    @Binding var showErrorAlert: Bool
    let router: Router

    func makeUIView(context _: Context) -> some UIView {
        DirectDebitWebview(setupType: setupType, showErrorAlert: $showErrorAlert, router: router)
    }

    func updateUIView(_: UIViewType, context _: Context) {}
}

public struct DirectDebitSetup: View {
    @State var showCancelAlert: Bool = false
    @State var showErrorAlert: Bool = false
    @State var showNotSupported: Bool = false

    @StateObject var router = Router()
    let setupType: SetupType

    public init(
        setupType: SetupType? = nil
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
                            buttonAction: {
                                router.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    NotificationCenter.default.post(
                                        name: .openChat,
                                        object: ChatType.newConversation
                                    )
                                }
                            }
                        ),
                        dismissButton: .init(
                            buttonAction: {
                                router.dismiss()
                            }
                        )
                    )
                )
            } else if showCancelAlert {
                DirectDebitSetupRepresentable(setupType: setupType, showErrorAlert: $showErrorAlert, router: router)
                    .alert(isPresented: $showCancelAlert) {
                        cancelAlert()
                    }
            } else {
                DirectDebitSetupRepresentable(setupType: setupType, showErrorAlert: $showErrorAlert, router: router)
                    .alert(isPresented: $showErrorAlert) {
                        errorAlert()
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
        .configureTitle(
            setupType == .replacement
                ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
        )
        .embededInNavigation(router: router, options: .navigationType(type: .large), tracking: self)
    }

    private var dismissButton: some View {
        hText(
            setupType == .postOnboarding ? L10n.PayInIframePostSign.skipButton : L10n.generalCancelButton,
            style: .heading1
        )
        .onTapGesture {
            if showNotSupported {
                router.dismiss()
            } else {
                showCancelAlert = true
            }
        }
    }

    private func cancelAlert() -> SwiftUI.Alert {
        Alert(
            title: Text(L10n.PayInIframeInAppCancelAlert.title),
            message: Text(L10n.PayInIframeInAppCancelAlert.body),
            primaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.proceedButton)) {
                router.dismiss()
            },
            secondaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.dismissButton))
        )
    }

    private func errorAlert() -> SwiftUI.Alert {
        Alert(
            title: Text(L10n.generalError),
            message: Text(L10n.somethingWentWrong),
            primaryButton: .default(Text(L10n.generalRetry)),
            secondaryButton: .cancel(Text(L10n.alertCancel)) {
                router.dismiss()
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
