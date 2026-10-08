import SwiftUI
import hCore
import hCoreUI

// Derived from hCoreUI's `ImportantInformationView` with the title/subtitle header dropped: the
// message is the whole card, so the card itself carries the tap, the state and the one VoiceOver
// element rather than nesting a confirmation row inside an explanatory one.
struct PaymentConfirmationCard: View {
    let message: String
    @Binding var isConfirmed: Bool

    // The message is a full sentence rather than a two-word "I understand", so the box tracks the
    // text instead of staying at a fixed 24pt while the label grows to 2.5x.
    @ScaledMetric private var checkboxSize: CGFloat = 24

    private static let toggleAnimationDuration: CGFloat = 0.2
    private static let checkboxCornerRadius: CGFloat = 6

    var body: some View {
        hRow {
            hText(message, style: .label)
                .foregroundColor(messageTextColor)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            checkbox
        }
        .background(
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(backgroundColor)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: Self.toggleAnimationDuration)) {
                isConfirmed.toggle()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isConfirmed ? .isSelected : [])
        .accessibilityLabel(message)
        .accessibilityValue(isConfirmed ? L10n.voiceoverAccepted : L10n.voiceoverNotAccepted)
    }

    // Forced light, as in `ImportantInformationView`, where the checkbox inherits it from the
    // confirmation row. Without it the same tokens would resolve differently in dark mode.
    @ViewBuilder
    private var checkbox: some View {
        if isConfirmed {
            hCoreUIAssets.checkmark.view
                .foregroundColor(checkmarkColor)
                .frame(width: checkboxSize, height: checkboxSize)
                .background(
                    RoundedRectangle(cornerRadius: Self.checkboxCornerRadius)
                        .fill(hSignalColor.Green.element)
                )
                .colorScheme(.light)
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: Self.checkboxCornerRadius)
                .strokeBorder(hBorderColor.secondary, lineWidth: 2)
                .frame(width: checkboxSize, height: checkboxSize)
                .colorScheme(.light)
                .hUseLightMode
                .accessibilityHidden(true)
        }
    }

    // The card turns a light green in both schemes, so the confirmed text is pinned to its light
    // resolution rather than flipping to white on a light fill.
    @hColorBuilder
    private var messageTextColor: some hColor {
        if isConfirmed {
            hTextColor.Opaque.primary.colorFor(.light, .base)
        } else {
            hTextColor.Opaque.primary
        }
    }

    @hColorBuilder
    private var checkmarkColor: some hColor {
        hColorScheme(light: hTextColor.Opaque.negative, dark: hTextColor.Opaque.primary)
    }

    @hColorBuilder
    private var backgroundColor: some hColor {
        if isConfirmed {
            hSignalColor.Green.fill
        } else {
            hSurfaceColor.Opaque.primary
        }
    }
}

@available(iOS 17.0, *)
#Preview("Not confirmed") {
    @Previewable @State var isConfirmed = false
    Localization.Locale.currentLocale.send(.en_SE)
    return hSection {
        PaymentConfirmationCard(message: L10n.paymentsAddSwishPayoutInfo, isConfirmed: $isConfirmed)
    }
    .sectionContainerStyle(.transparent)
}

@available(iOS 17.0, *)
#Preview("Confirmed") {
    @Previewable @State var isConfirmed = true
    Localization.Locale.currentLocale.send(.en_SE)
    return hSection {
        PaymentConfirmationCard(message: L10n.paymentsAddSwishPayoutInfo, isConfirmed: $isConfirmed)
    }
    .sectionContainerStyle(.transparent)
}
