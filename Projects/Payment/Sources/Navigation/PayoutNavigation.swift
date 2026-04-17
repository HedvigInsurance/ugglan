import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutNavigation: View {
    @StateObject private var router = NavigationRouter()
    @StateObject private var paymentMethodRouter = NavigationRouter()

    @State private var showConnectPayoutMethod: PaymentProvider?
    @ObservedObject private var paymentsNavigationVm: PaymentsNavigationViewModel
    init(
        paymentsNavigationVm: PaymentsNavigationViewModel
    ) {
        self.paymentsNavigationVm = paymentsNavigationVm
    }

    public var body: some View {
        if let paymentStatusViewModel = paymentsNavigationVm.paymentStatusViewModel {
            hNavigationStack(router: router, tracking: PayoutRouterAction.changeMethod) {
                PayoutChangeMethodScreen(vm: paymentStatusViewModel) { provider in
                    showConnectPayoutMethod = provider
                }
                .navigationTitle(L10n.payoutSelectPayoutMethod)
                .withDismissButton()
                .routerDestination(for: PayoutRouterAction.self, options: .hidesBackButton) { type in
                    switch type {
                    case .payoutMethod:
                        PayoutSelectedMethodScreen(vm: paymentStatusViewModel, withCloseButton: true)
                            .withDismissButton()
                    case .changeMethod:
                        PayoutChangeMethodScreen(vm: paymentStatusViewModel) { provider in
                            showConnectPayoutMethod = provider
                        }
                    }
                }
            }
            .detent(
                item: $showConnectPayoutMethod,
                presentationStyle: showConnectPayoutMethod?.detentPresentationStyle ?? .detent(style: [.large]),
                options: .constant(showConnectPayoutMethod?.options ?? [])
            ) { [weak paymentMethodRouter] paymentProvider in
                switch paymentProvider {
                case .nordea:
                    NordeaPayoutSetupScreen() {
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        store.send(.fetchPaymentStatus)
                        paymentMethodRouter?.dismiss()
                        router.push(PayoutRouterAction.payoutMethod)
                        Toasts.success()
                    }
                    .navigationTitle(PaymentProvider.nordea.payoutTitle)
                    .embededInNavigation(
                        router: paymentMethodRouter ?? NavigationRouter(),
                        tracking: PaymentProvider.nordea
                    )

                case .swish:
                    SwishPayoutSetupScreen() {
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        store.send(.fetchPaymentStatus)
                        paymentMethodRouter?.dismiss()
                        router.push(PayoutRouterAction.payoutMethod)

                        Toasts.success()
                    }
                    .navigationTitle(PaymentProvider.swish.payoutTitle)
                    .embededInNavigation(
                        router: paymentMethodRouter ?? NavigationRouter(),
                        tracking: PaymentProvider.swish
                    )
                case .trustly:
                    DirectDebitSetup(router: paymentMethodRouter) {
                        paymentMethodRouter?.dismiss()
                        router.push(PayoutRouterAction.payoutMethod)
                        Toasts.success()
                    }
                case .invoice, .unknown:
                    UpdateAppScreen() {}
                        .withAlertDismiss()
                }
            }
        }
    }
}

@MainActor
extension PaymentProvider {
    fileprivate var detentPresentationStyle: DetentPresentationStyle {
        switch self {
        case .trustly, .unknown, .invoice:
            return .detent(style: [.large])
        case .swish, .nordea:
            return .detent(style: [.height])
        }
    }

    fileprivate var options: DetentPresentationOption {
        switch self {
        case .trustly:
            return [.disableDismissOnScroll, .withoutGrabber]
        case .swish, .nordea, .unknown, .invoice:
            return []
        }
    }
}

extension PaymentProvider: TrackingViewNameProtocol, NavigationTitleProtocol {
    public var nameForTracking: String {
        switch self {
        case .trustly:
            String(describing: DirectDebitSetup.self)
        case .swish:
            String(describing: SwishPayoutSetupScreen.self)
        case .nordea:
            String(describing: NordeaPayoutSetupScreen.self)
        case .invoice:
            String(describing: UpdateAppScreen.self)
        case .unknown:
            String(describing: UpdateAppScreen.self)
        }
    }

    public var navigationTitle: String? {
        payoutTitle
    }
}

private enum PayoutRouterAction: Hashable, TrackingViewNameProtocol {
    case changeMethod
    case payoutMethod

    var nameForTracking: String {
        switch self {
        case .changeMethod:
            return String(describing: PayoutChangeMethodScreen.self)
        case .payoutMethod:
            return String(describing: PayoutSelectedMethodScreen.self)
        }
    }
}
