import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentAddPaymentMethod: View {
    @AppObservedObject var store: PaymentStore
    @Environment(\.dismiss) private var dismiss

    @State private var selected: PaymentProvider?
    @State private var providerToSetUp: PaymentProvider?
    @State private var connectedProvider: PaymentProvider?

    var body: some View {
        hForm {
            formContent
        }
        .hFormAttachToBottom {
            bottomContent
        }
        .hFormTitle(
            title: .init(.small, .body1, title, alignment: .center),
            subTitle: .init(.small, .body1, subtitle, alignment: .center)
        )
        .hFormContentPosition(.compact)
        .handlePaymentSetup(
            for: $providerToSetUp,
            phoneNumber: store.paymentStatusData?.memberPhoneNumber
        ) { provider in
            withAnimation { connectedProvider = provider }
        }
    }

    @ViewBuilder
    private var formContent: some View {
        if let provider = connectedProvider {
            PaymentConnectionPairGraphic(provider: provider, outcome: .success)
                .padding(.vertical, .padding96)
        } else {
            PaymentMethodPickerGraphic(selected: selected)
                .padding(.vertical, .padding64)
        }
    }

    @ViewBuilder
    private var bottomContent: some View {
        if let connectedProvider {
            confirmationContent(for: connectedProvider)
        } else {
            pickerContent
        }
    }

    @ViewBuilder
    private var pickerContent: some View {
        if let methods = store.paymentStatusData?.availablePayinMethods {
            hSection {
                hRadioOptionList(methods, id: \.provider, spacing: .padding8) { method in
                    PaymentMethodRow(payin: method.provider, selection: $selected)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        hSection {
            VStack(spacing: .padding8) {
                hButton(.large, .primary, content: .init(title: L10n.paymentConnectTitle)) {
                    providerToSetUp = selected
                }
                .disabled(selected == nil)
                hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                    dismiss()
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private func confirmationContent(for provider: PaymentProvider) -> some View {
        VStack(spacing: .padding16) {
            hText(L10n.paymentChangeFootnote, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .multilineTextAlignment(.center)
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var title: String {
        if let connectedProvider {
            return connectedTitle(for: connectedProvider)
        }
        return L10n.paymentConnectTitle
    }

    private var subtitle: String {
        if connectedProvider == .swish {
            return L10n.paymentSwishSuccessSubtitle
        }
        if connectedProvider != nil {
            return L10n.paymentTrustlySuccessSubtitle
        }
        return L10n.paymentConnectSubtitle
    }

    private func connectedTitle(for provider: PaymentProvider) -> String {
        if provider == .swish {
            return L10n.paymentSwishSuccessTitle
        }
        return "\(provider.payinTitle) \(L10n.paymentOptionConnectedLabel)"
    }
}

@MainActor
private func setUpPreviewStore() {
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
        layout: .other,
        memberPhoneNumber: "0735328847"
    )
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
}

#Preview("Pick a method") {
    setUpPreviewStore()
    return PaymentAddPaymentMethod()
}
