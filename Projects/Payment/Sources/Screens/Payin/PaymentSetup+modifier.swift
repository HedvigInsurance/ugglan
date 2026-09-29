import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

extension View {
    func handlePaymentSetup(
        for provider: Binding<PaymentProvider?>,
        phoneNumber: String? = nil,
        showSuccess: Bool = false,
        onSuccess: @escaping (PaymentProvider) -> Void = { _ in }
    ) -> some View {
        modifier(
            PaymentSetupDetent(
                provider: provider,
                phoneNumber: phoneNumber,
                showSuccess: showSuccess,
                onSuccess: onSuccess
            )
        )
    }

    public func handleSwishPayinSetup(presented: Binding<Bool>) -> some View {
        modifier(PayinSetupDeepLinkDetent(provider: .swish, presented: presented))
    }

    public func handleDirectDebitSetup(presented: Binding<Bool>) -> some View {
        modifier(PayinSetupDeepLinkDetent(provider: .trustly, presented: presented))
    }
}

struct PaymentSetupDetent: ViewModifier {
    @Binding var provider: PaymentProvider?
    let phoneNumber: String?
    let showSuccess: Bool
    var additionalOptions: DetentPresentationOption = []
    let onSuccess: (PaymentProvider) -> Void
    @State private var connectedProvider: PaymentProvider?

    func body(content: Content) -> some View {
        content
            .detent(
                item: $provider,
                presentationStyle: provider?.payinSetupPresentationStyle ?? .detent(style: [.large]),
                options: .constant((provider?.payinSetupPresentationOptions ?? []).union(additionalOptions))
            ) { presented in
                PayinSetupScreen(provider: presented, phoneNumber: phoneNumber) { setupSucceeded(presented) }
            }
            // Not dismissable by swipe, so Continue is always what finishes the flow and refreshes.
            .detent(
                item: $connectedProvider,
                options: .constant([.alwaysOpenOnTop, .disableDismissOnScroll])
            ) { connected in
                PaymentAddPaymentMethod(connectedProvider: connected) { provider in
                    finish(provider)
                }
                .hFormContentPosition(.compact)
            }
    }

    private func setupSucceeded(_ connected: PaymentProvider) {
        guard showSuccess else {
            finish(connected)
            return
        }
        Task {
            provider = nil
            // Let the setup detent finish dismissing before presenting the confirmation.
            await delay(0.1)
            connectedProvider = connected
        }
    }

    private func finish(_ connected: PaymentProvider) {
        provider = nil
        connectedProvider = nil
        onSuccess(connected)
        PaymentStore.refreshStatusDetached()
    }
}

/// `.alwaysOpenOnTop` because a deep link can arrive while something else is already showing.
private struct PayinSetupDeepLinkDetent: ViewModifier {
    let provider: PaymentProvider
    @Binding var presented: Bool
    /// The deep link carries no phone number of its own, so the flow falls back to the one
    /// fetched with the payment methods.
    @AppState private var store: PaymentStore

    func body(content: Content) -> some View {
        content
            .modifier(
                PaymentSetupDetent(
                    provider: Binding(
                        get: { presented ? provider : nil },
                        set: { presented = $0 != nil }
                    ),
                    phoneNumber: store.paymentStatusData?.memberPhoneNumber,
                    showSuccess: true,
                    additionalOptions: .alwaysOpenOnTop,
                    onSuccess: { _ in }
                )
            )
    }
}

private struct PayinSetupScreen: View {
    let provider: PaymentProvider
    let phoneNumber: String?
    let onSuccess: () -> Void

    var body: some View {
        switch provider {
        case .trustly:
            DirectDebitSetup(onSuccess: onSuccess)
        case .swish:
            SwishPayinSetupScreen(phoneNumber: phoneNumber, onSuccess: { onSuccess() })
        case .nordea, .invoice, .unknown:
            UpdateAppScreen {}.withAlertDismiss()
        }
    }
}
