import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

/// What happens once a provider's pay-in setup succeeds.
enum PayinSetupCompletion {
    /// Dismiss the setup and show a non-swipeable `PaymentAddPaymentMethod` confirmation.
    case showConfirmation
    /// Dismiss the setup and hand the connected provider to the caller.
    case custom((PaymentProvider) -> Void)
}

extension View {
    func handlePayinSetup(
        for provider: Binding<PaymentProvider?>,
        phoneNumber: String? = nil,
        additionalOptions: DetentPresentationOption = [],
        completion: PayinSetupCompletion
    ) -> some View {
        modifier(
            PayinSetupDetent(
                provider: provider,
                phoneNumber: phoneNumber,
                additionalOptions: additionalOptions,
                completion: completion
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

private struct PayinSetupDetent: ViewModifier {
    @Binding var provider: PaymentProvider?
    let phoneNumber: String?
    let additionalOptions: DetentPresentationOption
    let completion: PayinSetupCompletion
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
        switch completion {
        case .custom:
            finish(connected)
        case .showConfirmation:
            Task {
                provider = nil
                // Let the setup detent finish dismissing before presenting the confirmation.
                await delay(0.1)
                connectedProvider = connected
            }
        }
    }

    private func finish(_ connected: PaymentProvider) {
        provider = nil
        connectedProvider = nil
        if case let .custom(onSuccess) = completion {
            onSuccess(connected)
        }
        PaymentStore.refreshStatusDetached()
    }
}

private struct PayinSetupDeepLinkDetent: ViewModifier {
    let provider: PaymentProvider
    @Binding var presented: Bool
    /// The deep link carries no phone number of its own, so the flow falls back to the one
    /// fetched with the payment methods.
    @AppState private var store: PaymentStore

    func body(content: Content) -> some View {
        content
            .handlePayinSetup(
                for: Binding(
                    get: { presented ? provider : nil },
                    set: { presented = $0 != nil }
                ),
                phoneNumber: store.paymentStatusData?.memberPhoneNumber,
                // A deep link can arrive while something else is already showing.
                additionalOptions: .alwaysOpenOnTop,
                completion: .showConfirmation
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
            SwishPayinSetupScreen(phoneNumber: phoneNumber, onSuccess: onSuccess)
        case .nordea, .invoice, .unknown:
            UpdateAppScreen {}.withAlertDismiss()
        }
    }
}
