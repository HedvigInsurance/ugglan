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
                switch presented {
                case .trustly:
                    DirectDebitSetup(onSuccess: { connected(presented) })
                case .swish:
                    SwishPayinSetupScreen(phoneNumber: phoneNumber, onSuccess: { connected(presented) })
                case .nordea, .invoice, .unknown:
                    UpdateAppScreen {}.withAlertDismiss()
                }
            }
    }

    private func connected(_ provider: PaymentProvider) {
        self.provider = nil
        onSuccess(provider)
        PaymentStore.refreshStatusDetached()
    }
}
