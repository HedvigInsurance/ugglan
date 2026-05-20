import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayinChangeMethodScreen: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var paymentMethodRouter = NavigationRouter()
    @State private var showConnectPayinMethod: PaymentProvider?

    var body: some View {
        hForm {
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentStatusData
                }
            ) { paymentStatusData in
                if let paymentStatusData {
                    VStack(spacing: .padding4) {
                        ForEach(paymentStatusData.availablePayinMethods, id: \.provider) { method in
                            hSection {
                                hRow {
                                    VStack(alignment: .leading, spacing: .padding4) {
                                        hText(method.provider.payinTitle)
                                        hText(method.provider.payinSubtitle, style: .label)
                                            .foregroundColor(hTextColor.Translucent.secondary)
                                    }
                                    Spacer()
                                }
                                .withChevronAccessory
                                .onTap {
                                    showConnectPayinMethod = method.provider
                                }
                            }
                        }
                    }
                }
            }
        }
        .detent(
            item: $showConnectPayinMethod,
            presentationStyle: showConnectPayinMethod?.payinDetentPresentationStyle ?? .detent(style: [.large]),
            options: .constant(showConnectPayinMethod?.payinOptions ?? [])
        ) { [weak router, weak paymentMethodRouter] paymentProvider in
            let onSuccess = { [weak paymentMethodRouter] in
                let store: PaymentStore = globalPresentableStoreContainer.get()
                store.send(.fetchPaymentStatus)
                paymentMethodRouter?.dismiss()
                router?.dismiss()
            }
            switch paymentProvider {
            case .trustly:
                DirectDebitSetup(router: paymentMethodRouter, onSuccess: onSuccess)
            case .swish:
                SwishPayinSetupScreen(onSuccess: onSuccess)
                    .navigationTitle(PaymentProvider.swish.payinTitle)
                    .embededInNavigation(
                        router: paymentMethodRouter ?? NavigationRouter(),
                        tracking: PaymentProvider.swish
                    )
            case .invoice, .nordea, .unknown:
                UpdateAppScreen() {}
                    .withAlertDismiss()
            }
        }
    }
}

extension PaymentProvider {
    var payinTitle: String {
        switch self {
        case .nordea: return L10n.bankPayoutMethodCardTitle
        case .swish: return "Swish"
        case .trustly: return L10n.paymentsAutogiroLabel
        case .invoice: return L10n.paymentsInvoice
        case .unknown: return ""
        }
    }

    var payinSubtitle: String {
        switch self {
        case .nordea: return ""
        case .swish: return "Pay with Swish"
        case .trustly: return "Pay with direct debit"  //L10n.payinMethodTrustlyDescription
        case .invoice: return "Receive your invoice in Kivra"  //L10n.payinMethodInvoiceDescription
        case .unknown: return ""
        }
    }
}

@MainActor
extension PaymentProvider {
    fileprivate var payinDetentPresentationStyle: DetentPresentationStyle {
        switch self {
        case .trustly, .unknown, .invoice:
            return .detent(style: [.large])
        case .swish, .nordea:
            return .detent(style: [.height])
        }
    }

    fileprivate var payinOptions: DetentPresentationOption {
        switch self {
        case .trustly:
            return [.disableDismissOnScroll, .withoutGrabber]
        case .swish, .nordea, .unknown, .invoice:
            return []
        }
    }
}

#Preview {
    PayinChangeMethodScreen()
        .environmentObject(NavigationRouter())
        .environmentObject(PaymentsNavigationViewModel())
        .onAppear {
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .needsSetup,
                        chargingDay: nil,
                        defaultPayinMethod: nil,
                        payinMethods: [],
                        defaultPayoutMethod: nil,
                        payoutMethods: [],
                        availableMethods: [
                            .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                            .init(provider: .invoice, supportsPayin: true, supportsPayout: false),
                        ]
                    )
                )
            )
        }
}
