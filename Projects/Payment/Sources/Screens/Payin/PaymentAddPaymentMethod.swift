import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentAddPaymentMethod: View {
    @AppObservedObject var store: PaymentStore
    @Environment(\.dismiss) private var dismiss

    @State private var selected: AvailablePaymentMethod?
    @State private var providerToSetUp: PaymentProvider?
    @StateObject private var setupRouter = NavigationRouter()

    var body: some View {
        hForm {
            PaymentMethodPickerGraphic(selected: selected?.provider)
                .padding(.vertical, .padding64)
        }
        .hFormAttachToBottom {
            if let methods = store.paymentStatusData?.availablePayinMethods {
                hSection {
                    hRadioOptionList(methods, id: \.provider, spacing: .padding8) { method in
                        PaymentMethodRow(payin: method, selection: $selected)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            hSection {
                VStack(spacing: .padding8) {
                    hButton(.large, .primary, content: .init(title: L10n.paymentConnectTitle)) {
                        connect()
                    }
                    .disabled(selected == nil)
                    hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                        dismiss()
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormTitle(
            title: .init(.small, .body1, L10n.paymentConnectTitle, alignment: .center),
            subTitle: .init(.small, .body1, L10n.paymentConnectSubtitle, alignment: .center)
        )
        .hFormContentPosition(.compact)
        .detent(
            item: $providerToSetUp,
            presentationStyle: providerToSetUp?.payinSetupPresentationStyle ?? .detent(style: [.large]),
            options: .constant(providerToSetUp?.payinSetupPresentationOptions ?? [])
        ) { provider in
            let onSuccess = {
                providerToSetUp = nil
                dismiss()
                Toasts.success()
                PaymentStore.refreshStatusDetached()
            }
            switch provider {
            case .trustly:
                DirectDebitSetup(router: setupRouter, onSuccess: onSuccess)
            case .swish, .nordea, .invoice, .unknown:
                UpdateAppScreen {}
                    .withAlertDismiss()
            }
        }
    }

    /// Swish has no pay-in setup flow yet: `PaymentMethodSetupType` only exposes `.trustly`,
    /// `.nordeaPayout` and `.swishPayout`, so there is nothing to present. Route it here once
    /// the backend gains a pay-in equivalent.
    private func connect() {
        guard let provider = selected?.provider else { return }
        switch provider {
        case .trustly, .nordea, .invoice, .unknown:
            providerToSetUp = provider
        case .swish:
            break  // TODO: present the Swish pay-in setup flow when it exists.
        }
    }
}

#Preview {
    let store: PaymentStore = globalAppStateContainer.get()
    store.paymentStatusData = .init(
        status: .needsSetup,
        chargingDay: 27,
        defaultPayinMethod: nil,
        payinMethods: [],
        defaultPayoutMethod: nil,
        payoutMethods: [],
        availableMethods: [
            .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
            .init(provider: .swish, supportsPayin: true, supportsPayout: true),
            .init(provider: .invoice, supportsPayin: true, supportsPayout: false),
        ],
        missingConnection: .payin,
        layout: .other
    )
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return PaymentAddPaymentMethod()
}
