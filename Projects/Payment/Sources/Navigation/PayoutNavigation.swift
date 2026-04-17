import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutNavigation: View {
    @Environment(\.dismiss) var dissmiss
    @StateObject private var router = NavigationRouter()
    @State private var showConnectPayoutMethod: PaymentProvider?
    @ObservedObject private var paymentsNavigationVm: PaymentsNavigationViewModel
    init(
        paymentsNavigationVm: PaymentsNavigationViewModel
    ) {
        self.paymentsNavigationVm = paymentsNavigationVm
    }

    public var body: some View {
        if let paymentStatusViewModel = paymentsNavigationVm.paymentStatusViewModel {
            hNavigationStack(router: router, tracking: PayoutRouterAction.selectPayoutMethod) {
                PayoutChangeMethodScreen(vm: paymentStatusViewModel) { provider in
                    showConnectPayoutMethod = provider
                }
                .navigationTitle(L10n.payoutSelectPayoutMethod)
                .withAlertDismiss()
            }
            .detent(
                item: $showConnectPayoutMethod,
                presentationStyle: showConnectPayoutMethod?.detentPresentationStyle ?? .detent(style: [.large]),
                options: .constant(showConnectPayoutMethod?.options ?? [])
            ) { paymentProvider in
                switch paymentProvider {
                case .nordea:
                    NordeaPayoutSetupScreen() {
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        store.send(.fetchPaymentStatus)
                        dissmiss()
                        Toasts.success()
                    }
                    .navigationTitle(PaymentProvider.nordea.payoutTitle)
                    .embededInNavigation(tracking: PaymentProvider.nordea)

                case .swish:
                    SwishPayoutSetupScreen() {
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        store.send(.fetchPaymentStatus)
                        dissmiss()
                        Toasts.success()
                    }
                    .navigationTitle(PaymentProvider.swish.payoutTitle)
                    .embededInNavigation(tracking: PaymentProvider.swish)
                case .trustly:
                    DirectDebitSetup() {
                        dissmiss()
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
    case selectPayoutMethod

    var nameForTracking: String {
        switch self {
        case .selectPayoutMethod:
            return String(describing: PayoutChangeMethodScreen.self)
        }
    }
}
