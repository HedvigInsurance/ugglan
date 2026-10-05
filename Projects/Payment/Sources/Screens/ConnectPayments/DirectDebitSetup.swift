import AppStateContainer
import Combine
import Foundation
import SwiftUI
import TrustlyIosSdk
import WebKit
import hCore
import hCoreUI

private class DirectDebitWebview: UIView {
    var paymentService = hPaymentService()
    @AppState var paymentStore: PaymentStore
    var cancellables = Set<AnyCancellable>()
    let vc = UIViewController()
    @Binding var showErrorAlert: Bool
    let router: NavigationRouter
    let onSuccess: (() -> Void)?

    private let activityIndicator = UIActivityIndicatorView()
    private var trustlyWebView: TrustlyWKWebView?
    private var coordinator: TrustlyWebViewCoordinator?
    private var hasFinished = false

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

        vc.view = UIView()
        vc.view.backgroundColor = hBackgroundColor.primary.uiColor()
        addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }

        presentActivityIndicator()
        observeForeground()

        Task {
            await startRegistration()
        }
    }

    private func presentActivityIndicator() {
        activityIndicator.style = .large
        activityIndicator.color = .brand(.primaryText())
        activityIndicator.startAnimating()

        vc.view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func startRegistration() async {
        do {
            let result = try await paymentService.setupPaymentMethod(.trustly)
            guard let urlString = result.url, let url = URL(string: urlString) else {
                showErrorAlert = true
                return
            }
            presentCheckout(at: url)
        } catch {
            showErrorAlert = true
        }
    }

    private func presentCheckout(at url: URL) {
        guard let trustlyWebView = TrustlyWKWebView(checkoutUrl: url.absoluteString, frame: vc.view.bounds) else {
            showErrorAlert = true
            return
        }
        self.trustlyWebView = trustlyWebView

        trustlyWebView.onSuccess = { [weak self] in self?.finish(with: .success) }
        trustlyWebView.onError = { [weak self] in self?.finish(with: .failure) }
        // Backing out of the bank is a deliberate cancel, not an error.
        trustlyWebView.onAbort = { [weak self] in self?.dismissAfterAbort() }

        vc.view.insertSubview(trustlyWebView, belowSubview: activityIndicator)
        trustlyWebView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        // The SDK adds its web view at a fixed frame and never constrains it.
        guard let webView = trustlyWebView.subviews.compactMap({ $0 as? WKWebView }).first else {
            showErrorAlert = true
            return
        }
        webView.frame = trustlyWebView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.backgroundColor = .brand(.secondaryBackground())
        webView.isOpaque = false

        attachCoordinator(to: webView)
    }

    private func attachCoordinator(to webView: WKWebView) {
        let coordinator = TrustlyWebViewCoordinator(webView: webView, presentingViewController: vc)
        self.coordinator = coordinator

        coordinator.isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                self?.activityIndicator.alpha = isLoading ? 1 : 0
            }
            .store(in: &cancellables)
    }

    private func observeForeground() {
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self, !self.hasFinished else { return }
                // Without this the checkout sits on "waiting" until its polling catches up.
                self.trustlyWebView?.setReturnedFromApp()
            }
            .store(in: &cancellables)
    }

    private func finish(with type: DirectDebitResultType) {
        guard !hasFinished else { return }
        hasFinished = true
        showResultScreen(type: type)
    }

    private func dismissAfterAbort() {
        guard !hasFinished else { return }
        hasFinished = true
        router.dismiss()
    }

    private func showResultScreen(type: DirectDebitResultType) {
        let directDebitResult = DirectDebitResult(
            type: type,
            action: { [weak router] in
                router?.dismiss()
            }
        )
        .environmentObject(router)

        if type == .success {
            onSuccess?()
            Task { [weak paymentStore] in await paymentStore?.fetchPaymentStatus() }
        }

        let debitResultHostingView = UIHostingController(rootView: directDebitResult)
        let backgroundView = UIView()
        backgroundView.backgroundColor = hBackgroundColor.primary.uiColor()
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

    @StateObject private var ownedRouter = NavigationRouter()
    @ObservedObject private var externalRouter: NavigationRouter
    private var hasExternalRouter: Bool
    var router: NavigationRouter { hasExternalRouter ? externalRouter : ownedRouter }
    private let isReplacingExistingMethod: Bool
    let onSuccess: (() -> Void)?

    public init(
        router: NavigationRouter? = nil,
        onSuccess: (() -> Void)? = nil
    ) {
        let store: PaymentStore = globalAppStateContainer.get()
        self.isReplacingExistingMethod = [PayinMethodStatus.active, PayinMethodStatus.pending]
            .contains(store.paymentStatusData?.status ?? .active)
        self.onSuccess = onSuccess
        self.hasExternalRouter = router != nil
        self._externalRouter = ObservedObject(wrappedValue: router ?? NavigationRouter())
    }

    public var body: some View {
        DirectDebitSetupRepresentable(
            showErrorAlert: showErrorAlertBinding,
            router: router,
            onSuccess: onSuccess
        )
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .cancel:
                cancelAlert()
            case .error:
                errorAlert()
            }
        }
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                dismissButton
            }
        }
        .navigationTitle(
            isReplacingExistingMethod
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
        hText(L10n.generalCancelButton, style: .heading1)
            .padding(.horizontal, .padding4)
            .fixedSize()
            .onTapGesture {
                activeAlert = .cancel
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

extension DirectDebitSetup: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: DirectDebitSetup.self)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    return DirectDebitSetup()
}
