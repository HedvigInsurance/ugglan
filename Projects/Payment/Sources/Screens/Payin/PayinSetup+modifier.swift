import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

/// What happens once a provider's pay-in setup succeeds.
enum PayinSetupCompletion {
    /// Dismiss the setup and show a non-swipeable `AddPaymentMethodScreen` confirmation.
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

    /// Opens a provider's pay-in setup directly, for the deep links that name one. Setting the
    /// binding is the whole trigger, so two deep links can never arm two setups at once.
    public func handlePayinSetupDeepLink(provider: Binding<PaymentProvider?>) -> some View {
        modifier(PayinSetupDeepLinkDetent(provider: provider))
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
                AddPaymentMethodScreen(connectedProvider: connected) { provider in
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
    @Binding var provider: PaymentProvider?
    /// The deep link carries no phone number of its own, so the flow falls back to the one
    /// fetched with the payment methods.
    @AppState private var store: PaymentStore

    func body(content: Content) -> some View {
        content
            .handlePayinSetup(
                for: $provider,
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
