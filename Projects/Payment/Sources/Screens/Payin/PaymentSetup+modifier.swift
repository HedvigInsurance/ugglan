import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

extension View {
    func handlePaymentSetup(
        for provider: Binding<PaymentProvider?>,
        phoneNumber: String? = nil,
        onSuccess: @escaping (PaymentProvider) -> Void = { _ in }
    ) -> some View {
        modifier(PaymentSetupDetent(provider: provider, phoneNumber: phoneNumber, onSuccess: onSuccess))
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
    let onSuccess: (PaymentProvider) -> Void

    func body(content: Content) -> some View {
        content
            .detent(
                item: $provider,
                presentationStyle: provider?.payinSetupPresentationStyle ?? .detent(style: [.large]),
                options: .constant(provider?.payinSetupPresentationOptions ?? [])
            ) { presented in
                PayinSetupScreen(provider: presented, phoneNumber: phoneNumber) { connected(presented) }
            }
    }

    private func connected(_ provider: PaymentProvider) {
        self.provider = nil
        onSuccess(provider)
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
            .detent(
                presented: $presented,
                presentationStyle: provider.payinSetupPresentationStyle,
                options: .constant(provider.payinSetupPresentationOptions.union(.alwaysOpenOnTop))
            ) {
                PayinSetupScreen(provider: provider, phoneNumber: store.paymentStatusData?.memberPhoneNumber) {
                    connected()
                }
            }
    }

    private func connected() {
        presented = false
        PaymentStore.refreshStatusDetached()
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
