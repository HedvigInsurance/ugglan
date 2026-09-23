import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodPickerList: View {
    let methods: [AvailablePaymentMethod]
    let direction: PaymentDirection
    @Binding var selected: PaymentProvider?
    let connectTitle: String
    let onConnect: () -> Void
    let onCancel: (() -> Void)?

    var body: some View {
        VStack(spacing: .padding16) {
            // Nothing to pick from until the status has been fetched, and an empty list would
            // still take up a section's worth of padding.
            if !methods.isEmpty {
                hSection {
                    hRadioOptionList(methods, id: \.provider, spacing: .padding8) { method in
                        PaymentMethodRow(method.provider, direction: direction, selection: $selected)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            hSection {
                VStack(spacing: .padding8) {
                    hButton(.large, .primary, content: .init(title: connectTitle)) {
                        onConnect()
                    }
                    .disabled(selected == nil)
                    if let onCancel {
                        hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                            onCancel()
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

@MainActor
private func previewPicker(
    _ direction: PaymentDirection,
    selected: PaymentProvider?,
    showsCancel: Bool = false
) -> some View {
    Localization.Locale.currentLocale.send(.en_SE)
    let onCancel: (() -> Void)? = showsCancel ? {} : nil
    let methods: [AvailablePaymentMethod] = [
        .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
        .init(provider: .swish, supportsPayin: true, supportsPayout: true),
        .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
    ]
    return hForm {
        PaymentMethodPickerGraphic(direction: direction, selected: selected)
            .padding(.vertical, .padding64)
    }
    .hFormAttachToBottom {
        PaymentMethodPickerList(
            methods: methods,
            direction: direction,
            selected: .constant(selected),
            connectTitle: L10n.generalContinueButton,
            onConnect: {},
            onCancel: onCancel
        )
    }
}

#Preview("Pay-in, nothing picked") { previewPicker(.payin, selected: nil, showsCancel: true) }

#Preview("Pay-in, Swish picked") { previewPicker(.payin, selected: .swish, showsCancel: true) }

#Preview("Pay-out, nothing picked") { previewPicker(.payout, selected: nil) }

#Preview("Pay-out, Swish picked") { previewPicker(.payout, selected: .swish) }
