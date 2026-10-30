import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentConnectFlowView: View {
    let direction: PaymentDirection
    let methods: [AvailablePaymentMethod]
    let title: hTitle
    var subTitle: hTitle? = nil
    let connectTitle: String
    var confirmationFootnote: String? = nil
    @Binding var selected: PaymentProvider?
    let connectedProvider: PaymentProvider?
    let onConnect: () -> Void
    let onCancel: (() -> Void)?
    let onContinue: () -> Void
    @AppObservedObject private var store: PaymentStore
    var body: some View {
        hForm {
            PaymentConnectionGraphic(
                direction: direction,
                provider: connectedProvider ?? selected,
                outcome: connectedProvider != nil ? .success : nil
            )
            .padding(.vertical, connectedProvider != nil ? .padding96 : .padding64)
        }
        .hFormTitle(title: title, subTitle: subTitle)
        .hFormAttachToBottom {
            bottomContent
        }
    }

    @ViewBuilder
    private var bottomContent: some View {
        if connectedProvider != nil {
            confirmationContent
        } else {
            VStack(spacing: .padding16) {
                if store.paymentStatusData?.hasAnyPayinMethod == false {
                    hText(L10n.paymentMethodRequiredFootnote, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .multilineTextAlignment(.center)
                }
                PaymentMethodPickerList(
                    methods: methods,
                    direction: direction,
                    selected: $selected,
                    connectTitle: connectTitle,
                    onConnect: onConnect,
                    onCancel: onCancel
                )
            }
        }
    }

    private var confirmationContent: some View {
        VStack(spacing: .padding16) {
            if let confirmationFootnote {
                hText(confirmationFootnote, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .multilineTextAlignment(.center)
            }
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    onContinue()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

@MainActor
private func previewConnectFlow(
    _ direction: PaymentDirection,
    selected: Binding<PaymentProvider?> = .constant(nil),
    connectedProvider: PaymentProvider? = nil
) -> some View {
    Localization.Locale.currentLocale.send(.en_SE)
    let methods: [AvailablePaymentMethod] = [
        .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
        .init(provider: .swish, supportsPayin: true, supportsPayout: true),
        .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
    ]
    let title: (String) -> hTitle = { .init(.navigationLike, .body1, $0, alignment: .center) }
    return PaymentConnectFlowView(
        direction: direction,
        // Call sites pass only the methods that support the direction, so mirror that here
        methods: methods.filter { direction == .payin ? $0.supportsPayin : $0.supportsPayout },
        title: title(connectedProvider == nil ? L10n.paymentConnectTitle : L10n.paymentSwishSuccessTitle),
        subTitle: title(connectedProvider == nil ? L10n.paymentConnectSubtitle : L10n.paymentSwishSuccessSubtitle),
        connectTitle: L10n.paymentConnectTitle,
        confirmationFootnote: connectedProvider == nil ? nil : L10n.paymentsAddSwishPayoutInfo,
        selected: selected,
        connectedProvider: connectedProvider,
        onConnect: {},
        onCancel: {},
        onContinue: {}
    )
}

#Preview("Pay-in, nothing picked") { previewConnectFlow(.payin) }

#Preview("Pay-in, Swish picked") { previewConnectFlow(.payin, selected: .constant(.swish)) }

#Preview("Pay-in, interactive") {
    // Tap a method in the live canvas to see the selection and graphic update
    @Previewable @State var selected: PaymentProvider?
    previewConnectFlow(.payin, selected: $selected)
        .animation(.default, value: selected)
}

#Preview("Pay-in, Swish connected") { previewConnectFlow(.payin, connectedProvider: .swish) }

#Preview("Pay-out, Swish picked") { previewConnectFlow(.payout, selected: .constant(.swish)) }

#Preview("Pay-out, interactive") {
    @Previewable @State var selected: PaymentProvider?
    previewConnectFlow(.payout, selected: $selected)
        .animation(.default, value: selected)
}
