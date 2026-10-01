import SwiftUI
import hCore
import hCoreUI

/// The shared "pick a provider → connect → confirm" screen, used in both directions.
///
/// Picker and confirmation share one `hForm` on purpose: `PaymentConnectionGraphic` animates on
/// `provider` and `outcome`, so it has to stay mounted for the hand-off to morph in place rather
/// than cut. Each direction keeps its own setup presentation, applied as a modifier from outside.
struct PaymentConnectFlowView: View {
    let direction: PaymentDirection
    let methods: [AvailablePaymentMethod]
    let title: hTitle
    var subTitle: hTitle? = nil
    let connectTitle: String
    let confirmationFootnote: String
    @Binding var selected: PaymentProvider?
    let connectedProvider: PaymentProvider?
    let onConnect: () -> Void
    /// `nil` hides Cancel, for a picker a surrounding flow already owns the way out of.
    let onCancel: (() -> Void)?
    let onContinue: () -> Void

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

    private var confirmationContent: some View {
        VStack(spacing: .padding16) {
            hText(confirmationFootnote, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .multilineTextAlignment(.center)
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    onContinue()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
