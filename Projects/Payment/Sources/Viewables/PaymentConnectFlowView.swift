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
