import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutChangeMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var paymentMethodRouter = NavigationRouter()
    @State private var showConnectPayoutMethod: PaymentProvider?

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(vm.paymentStatusData.availablePayoutMethods, id: \.provider) { method in
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: .padding4) {
                                hText(method.provider.payoutTitle)
                                hText(method.provider.payoutSubtitle, style: .label)
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            }
                            Spacer()
                        }
                        .withChevronAccessory
                        .onTap {
                            showConnectPayoutMethod = method.provider
                        }
                    }
                }
            }
        }
        .detent(
            item: $showConnectPayoutMethod,
            presentationStyle: showConnectPayoutMethod?.detentPresentationStyle ?? .detent(style: [.large]),
            options: .constant(showConnectPayoutMethod?.options ?? [])
        ) { [weak router, weak paymentMethodRouter] paymentProvider in
            let onSuccess = { [weak paymentMethodRouter] in
                let store: PaymentStore = globalPresentableStoreContainer.get()
                store.send(.fetchPaymentStatus)
                paymentMethodRouter?.dismiss()
                router?.pop()
                Toasts.success()
            }
            switch paymentProvider {
            case .nordea:
                NordeaPayoutSetupScreen(onSuccess: onSuccess)
                    .navigationTitle(PaymentProvider.nordea.payoutTitle)
                    .embededInNavigation(
                        router: paymentMethodRouter ?? NavigationRouter(),
                        tracking: PaymentProvider.nordea
                    )
            case .swish:
                SwishPayoutSetupScreen(onSuccess: onSuccess)
                    .navigationTitle(PaymentProvider.swish.payoutTitle)
                    .embededInNavigation(
                        router: paymentMethodRouter ?? NavigationRouter(),
                        tracking: PaymentProvider.swish
                    )
            case .trustly:
                DirectDebitSetup(router: paymentMethodRouter, onSuccess: onSuccess)
            case .invoice, .unknown:
                UpdateAppScreen() {}
                    .withAlertDismiss()
            }
        }
    }
}

extension PaymentProvider {
    var payoutTitle: String {
        switch self {
        case .nordea: return L10n.bankPayoutMethodCardTitle
        case .swish: return "Swish"
        case .trustly: return "Trustly"
        case .invoice: return L10n.paymentsInvoice
        case .unknown: return ""
        }
    }

    var payoutSubtitle: String {
        switch self {
        case .nordea: return L10n.bankPayoutMethodCardDescription
        case .swish: return L10n.payoutMethodSwishDescription
        case .trustly: return L10n.payoutMethodTrustlyDescription
        case .invoice: return L10n.payoutMethodInvoiceDescription
        case .unknown: return ""
        }
    }
}

#Preview {
    PayoutChangeMethodScreen(
        vm: .init(
            paymentStatusData: .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: nil,
                payinMethods: [],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: [
                    .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                    .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                    .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                ]
            )
        )
    )
    .environmentObject(NavigationRouter())
    .environmentObject(PaymentsNavigationViewModel())
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

@MainActor
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
