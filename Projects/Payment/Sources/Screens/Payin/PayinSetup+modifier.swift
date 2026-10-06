import SwiftUI
import hCore
import hCoreUI

/// What happens once a provider's pay-in setup succeeds.
enum PayinSetupCompletion {
    case showConfirmation
    /// Dismiss the setup and hand the connected provider to the caller.
    case custom((PaymentProvider) -> Void)
}

extension View {
    func handlePayinSetup(
        for provider: Binding<PaymentProvider?>,
        additionalOptions: DetentPresentationOption = [],
        canChangeMethod: Bool = false,
        completion: PayinSetupCompletion
    ) -> some View {
        modifier(
            PayinSetupDetent(
                provider: provider,
                additionalOptions: additionalOptions,
                canChangeMethod: canChangeMethod,
                completion: completion
            )
        )
    }

    public func handlePayinSetupDeepLink(provider: Binding<PaymentProvider?>) -> some View {
        modifier(PayinSetupDeepLinkDetent(provider: provider))
    }
}

private struct PayinSetupDetent: ViewModifier {
    @Binding var provider: PaymentProvider?
    let additionalOptions: DetentPresentationOption
    /// Whether the setup was opened from a method picker the member can go back to.
    let canChangeMethod: Bool
    let completion: PayinSetupCompletion
    @State private var connectedProvider: PaymentProvider?

    func body(content: Content) -> some View {
        content
            .detent(
                item: $provider,
                presentationStyle: provider?.payinSetupPresentationStyle ?? .detent(style: [.large]),
                options: .constant((provider?.payinSetupPresentationOptions ?? []).union(additionalOptions))
            ) { presented in
                PayinSetupScreen(provider: presented, canChangeMethod: canChangeMethod) { setupSucceeded(presented) }
            }
            // Not dismissable by swipe, so Continue is always what finishes the flow and refreshes.
            .detent(
                item: $connectedProvider,
                options: .constant([.alwaysOpenOnTop, .disableDismissOnScroll])
            ) { connected in
                AddPaymentMethodScreen(connectedProvider: connected, confirmationFootnote: nil) { provider in
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
        if case let .custom(onSuccess) = completion {
            onSuccess(connected)
        }
        PaymentStore.refreshStatusDetached()
        Task {
            await delay(0.15)
            provider = nil
            connectedProvider = nil
        }
    }
}

private struct PayinSetupDeepLinkDetent: ViewModifier {
    @Binding var provider: PaymentProvider?

    func body(content: Content) -> some View {
        content
            .handlePayinSetup(
                for: $provider,
                // A deep link can arrive while something else is already showing.
                additionalOptions: .alwaysOpenOnTop,
                completion: .showConfirmation
            )
    }
}

private struct PayinSetupScreen: View {
    let provider: PaymentProvider
    let canChangeMethod: Bool
    let onSuccess: () -> Void

    var body: some View {
        switch provider {
        case .trustly:
            DirectDebitSetup(onSuccess: onSuccess)
        case .swish:
            SwishPayinConsentScreen(canChangeMethod: canChangeMethod, onConnected: { onSuccess() })
        case .nordea, .invoice, .unknown:
            UpdateAppScreen {}.withAlertDismiss()
        }
    }
}
