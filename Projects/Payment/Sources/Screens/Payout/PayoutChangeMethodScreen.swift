import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PayoutChangeMethodScreen: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var paymentMethodRouter = NavigationRouter()
    @State private var selected: PaymentProvider?
    @State private var showConnectPayoutMethod: PaymentProvider?
    @State private var connectedProvider: PaymentProvider?

    var body: some View {
        hForm {
            formContent
        }
        .hFormTitle(title: formTitle, subTitle: nil)
        .hFormAttachToBottom {
            bottomContent
        }
        .task {
            // Reached straight from a deep link as well as from the payout screen, so the list
            // can't assume someone else has already fetched the status.
            if store.paymentStatusData == nil {
                await store.fetchPaymentStatus()
            }
        }
        .detent(
            item: $showConnectPayoutMethod,
            presentationStyle: showConnectPayoutMethod?.payoutSetupPresentationStyle ?? .detent(style: [.large]),
            options: .constant(showConnectPayoutMethod?.payoutSetupPresentationOptions ?? [])
        ) { paymentProvider in
            let onSuccess = {
                PaymentStore.refreshStatusDetached()
                paymentMethodRouter.dismiss()
                connectedProvider = paymentProvider
            }
            switch paymentProvider {
            case .nordea:
                NordeaPayoutSetupScreen(onSuccess: onSuccess)
                    .navigationTitle(PaymentProvider.nordea.payoutTitle)
                    .embededInNavigation(router: paymentMethodRouter, tracking: PaymentProvider.nordea)
            case .swish:
                SwishPayoutSetupScreen(onSuccess: onSuccess)
                    .navigationTitle(PaymentProvider.swish.payoutTitle)
                    .embededInNavigation(router: paymentMethodRouter, tracking: PaymentProvider.swish)
            case .trustly:
                DirectDebitSetup(router: paymentMethodRouter, onSuccess: onSuccess)
            case .invoice, .unknown:
                UpdateAppScreen() {}
                    .withAlertDismiss()
            }
        }
    }

    @ViewBuilder
    private var formContent: some View {
        if let connectedProvider {
            PaymentConnectionPairGraphic(provider: connectedProvider, outcome: .success, direction: .payout)
                .padding(.vertical, .padding96)
        } else {
            PaymentMethodPickerGraphic(direction: .payout, selected: selected)
                .padding(.vertical, .padding64)
        }
    }

    @ViewBuilder
    private var bottomContent: some View {
        if connectedProvider != nil {
            confirmationContent
        } else {
            PaymentMethodPickerList(
                methods: store.paymentStatusData?.availablePayoutMethods ?? [],
                direction: .payout,
                selected: $selected,
                connectTitle: L10n.generalContinueButton,
                onConnect: { showConnectPayoutMethod = selected },
                onCancel: { router.dismiss() }
            )
        }
    }

    private var confirmationContent: some View {
        VStack(spacing: .padding16) {
            hText(L10n.onboardingConnectPaymentSwitchAccountsLater, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .multilineTextAlignment(.center)
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    router.dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var formTitle: hTitle {
        .init(
            .small,
            .body1,
            connectedProvider == nil ? L10n.payoutSelectPayoutMethod : L10n.paymentPayoutBankSuccessTitle,
            alignment: .center
        )
    }
}

#Preview {
    PayoutChangeMethodScreen()
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
