import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PayoutChangeMethodScreen: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var paymentMethodRouter = NavigationRouter()
    @State private var showConnectPayoutMethod: PaymentProvider?

    var body: some View {
        hForm {
            if let paymentStatusData = store.paymentStatusData {
                VStack(spacing: .padding4) {
                    ForEach(paymentStatusData.availablePayoutMethods, id: \.provider) { method in
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
        }
        .detent(
            item: $showConnectPayoutMethod,
            presentationStyle: showConnectPayoutMethod?.payoutSetupPresentationStyle ?? .detent(style: [.large]),
            options: .constant(showConnectPayoutMethod?.payoutSetupPresentationOptions ?? [])
        ) { [weak router, weak paymentMethodRouter] paymentProvider in
            let onSuccess = { [weak paymentMethodRouter] in
                let store: PaymentStore = globalAppStateContainer.get()
                Task { await store.fetchPaymentStatus() }
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

#Preview {
    PayoutChangeMethodScreen()
        .environmentObject(NavigationRouter())
        .environmentObject(PaymentsNavigationViewModel())
        .onAppear {
            let store: PaymentStore = globalAppStateContainer.get()
            store.paymentStatusData = .init(
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
                ],
                missingConnection: .payout,
                layout: .other
            )
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
