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
    @Inject var octopus: hOctopus
    @PresentableStore var paymentStore: PaymentStore
    var cancellables = Set<AnyCancellable>()
    let setupType: SetupType
    let vc = UIViewController()
    var webView = WKWebView()
    var webViewDelgate = WebViewDelegate(webView: .init())

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(setupType: SetupType) {
        self.setupType = setupType
        super.init(frame: .zero)

        vc.hidesBottomBarWhenPushed = true

        vc.isModalInPresentation = true

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

        let shouldDismissViewSignal = ReadWriteSignal<Bool>(false)
        let didFailToLoadWebViewSignal = ReadWriteSignal<Bool>(false)

        webViewDelgate.isLoading
            .sink { _ in
            } receiveValue: { loading in
                if loading { activityIndicator.alpha = 1 } else { activityIndicator.alpha = 0 }
            }
            .store(in: &cancellables)

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
                        self?.presentAlert()
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

        Task {
            await startRegistration()
        }

        webViewDelgate.decidePolicyForNavigationAction
            .sink { _ in
            } receiveValue: { [weak self] success in
                guard let self = self else {
                    return
                }
                self.showResultScreen(
                    type: success
                        ? .success(setupType: self.setupType)
                        : .failure(setupType: self.setupType)
                )
            }
            .store(in: &cancellables)

        self.addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
    }

    deinit {
        let a = ""
    }

    private func showResultScreen(type: DirectDebitResultType) {
        vc.navigationItem.setLeftBarButtonItems(nil, animated: true)

        let containerView = UIView()
        containerView.backgroundColor = .brand(.secondaryBackground())

        let directDebitResult = DirectDebitResult(type: type)  //rewrite

        switch type {
        case .success:
            paymentStore.send(.fetchPaymentStatus)
        case .failure:
            break
        }

        containerView.add(directDebitResult) { view in
            view.snp.makeConstraints { make in make.size.equalToSuperview()
                make.edges.equalToSuperview()
            }
        }
        .onValue { [weak self] success in
            self?.paymentStore.send(.fetchPaymentStatus)
        }
        .onError { [weak self] _ in
            Task {
                await self?.startRegistration()
            }
        }

        vc.view = containerView
    }

    private func startRegistration() async {
        vc.view = webView
        let mutation = OctopusGraphQL.RegisterDirectDebitMutation(clientContext: GraphQLNullable.none)

        do {
            let data = try await octopus.client.perform(mutation: mutation)
            if let url = URL(string: data.registerDirectDebit2.url) {
                let request = URLRequest(
                    url: url,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                    timeoutInterval: 10
                )
                webViewDelgate.result.send(url)
                webView.load(request)
            } else {
                presentAlert()
            }
        } catch {
            presentAlert()
        }
    }

    func presentAlert() {
        Alert(
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
    }
}

struct DirectDebitSetupRepresentable: UIViewRepresentable {
    let setupType: SetupType

    public func makeUIView(context: Context) -> some UIView {
        return DirectDebitWebview(setupType: setupType)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

public struct DirectDebitSetup: View {
    @PresentableStore var paymentStore: PaymentStore
    @State var showAlert: Bool = false

    let setupType: SetupType

    public init(
        setupType: SetupType = .initial
    ) {
        self.setupType = setupType
    }

    public var body: some View {
        DirectDebitSetupRepresentable(setupType: setupType)
            .toolbar {
                ToolbarItem(
                    placement: .navigationBarLeading
                ) {
                    hButton.MediumButton(type: .ghost) {
                        showAlert = true
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(L10n.PayInIframeInAppCancelAlert.title),
                    message: Text(L10n.PayInIframeInAppCancelAlert.body),
                    primaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.proceedButton)) {
                        paymentStore.send(.dismissPayment)
                    },
                    secondaryButton: .default(Text(L10n.PayInIframeInAppCancelAlert.dismissButton))
                )
            }
    }

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
            options: [.defaults, .autoPopSelfAndSuccessors]
        ) { action in
            if case .dismissPayment = action {
                DismissJourney()
            }
        }
        .configureTitle(
            self.setupType == .replacement ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
        )
    }

    public var journeyThenDismiss: some JourneyPresentation {
        journey { _, _ in
            return PopJourney()
        }
    }
}
