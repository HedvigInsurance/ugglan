import Apollo
import Combine
import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import WebKit
import hCore
import hCoreUI
import hGraphQL

private class DirectDebitWebview: UIView {
    @Inject var paymentService: hPaymentService
    @PresentableStore var paymentStore: PaymentStore
    var cancellables = Set<AnyCancellable>()
    let setupType: SetupType
    let vc = UIViewController()
    var webView = WKWebView()
    var webViewDelgate = WebViewDelegate(webView: .init())
    @Binding var showErrorAlert: Bool

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        setupType: SetupType,
        showErrorAlert: Binding<Bool>
    ) {
        self.setupType = setupType
        self._showErrorAlert = showErrorAlert
        super.init(frame: .zero)

        presentWebView()
        presentActivityIndicator()
        retryInBroswerFailedToLoad()
        checkForResult()

        Task {
            await startRegistration()
        }

        self.addSubview(vc.view)
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

        activityIndicator.snp.makeConstraints { make in make.edges.equalToSuperview()
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

    private func retryInBroswerFailedToLoad() {
        let didFailToLoadWebViewSignal = ReadWriteSignal<Bool>(false)
        let shouldDismissViewSignal = ReadWriteSignal<Bool>(false)

        let publisherDelay = Timer.TimerPublisher(interval: 5.0, runLoop: .main, mode: .default).autoconnect()
        Publishers.CombineLatest3(publisherDelay, webViewDelgate.isLoading, webViewDelgate.result)
            .sink { _ in
            } receiveValue: { [weak self] _, isLoading, URL in
                publisherDelay.upstream.connect().cancel()
                if isLoading {
                    didFailToLoadWebViewSignal.value = true
                    if let url = URL {
                        UIApplication.shared.open(url)
                        didFailToLoadWebViewSignal.value = true
                    } else {
                        self?.showErrorAlert = true
                    }
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(
            webViewDelgate.error,
            NotificationCenter.Publisher(center: .default, name: UIApplication.willEnterForegroundNotification)
        )
        .sink { _ in
        } receiveValue: { error, _ in
            shouldDismissViewSignal.value = true
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
        DispatchQueue.main.async { [weak self] in guard let self = self else { return }
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
                webViewDelgate.result.send(url)
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

    public func makeUIView(context: Context) -> some UIView {
        return DirectDebitWebview(setupType: setupType, showErrorAlert: $showErrorAlert)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

public struct DirectDebitSetup: View {
    @PresentableStore var paymentStore: PaymentStore
    @State var showCancelAlert: Bool = false
    @State var showErrorAlert: Bool = false

    let setupType: SetupType

    public init(
        setupType: SetupType = .initial
    ) {
        self.setupType = setupType
    }

    public var body: some View {
        Group {
            if showCancelAlert {
                DirectDebitSetupRepresentable(setupType: setupType, showErrorAlert: $showErrorAlert)
                    .alert(isPresented: $showCancelAlert) {
                        cancelAlert()
                    }
            } else {
                DirectDebitSetupRepresentable(setupType: setupType, showErrorAlert: $showErrorAlert)
                    .alert(isPresented: $showErrorAlert) {
                        errorAlert()
                    }
            }
        }
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                dismissButton
            }
        }
    }

    private var dismissButton: some View {
        hButton.MediumButton(type: .ghost) {
            showCancelAlert = true
        } content: {
            hText(setupType == .postOnboarding ? L10n.PayInIframePostSign.skipButton : L10n.generalCancelButton)
        }
    }

    private func cancelAlert() -> SwiftUI.Alert {
        return Alert(
            title: Text(L10n.PayInIframeInAppCancelAlert.title),
            message: Text(L10n.PayInIframeInAppCancelAlert.body),
            primaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.proceedButton)) {
                paymentStore.send(.dismissPayment)
            },
            secondaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.dismissButton))
        )
    }

    private func errorAlert() -> SwiftUI.Alert {
        return Alert(
            title: Text(L10n.generalError),
            message: Text(L10n.somethingWentWrong),
            primaryButton: .default(Text(L10n.generalRetry)),
            secondaryButton: .cancel(Text(L10n.alertCancel)) {
                paymentStore.send(.dismissPayment)
            }
        )
    }
}

public enum SetupType: Equatable {
    case initial
    case preOnboarding(monthlyNetCost: MonetaryAmount?)
    case replacement, postOnboarding
}

extension DirectDebitSetup {
    public func journey(
        @JourneyBuilder _ next: @escaping (_ success: Bool, _ paymentConnectionID: String?) -> any JourneyPresentation
    ) -> some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: self,
            style: .detented(.large),
            options: [.defaults, .autoPopSelfAndSuccessors, .largeNavigationBar]
        ) { action in
            if case .dismissPayment = action {
                DismissJourney()
            }
        }
        .configureTitle(
            self.setupType == .replacement ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
        )
        .enableModalInPresentation
    }

    public var journeyThenDismiss: some JourneyPresentation {
        journey { _, _ in
            return PopJourney()
        }
    }
}
