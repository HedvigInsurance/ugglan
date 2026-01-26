import SwiftUI
import hCore

public struct ImportantInformationView: View {
    let title: String
    let subtitle: String
    let confirmationMessage: String
    @Binding var isConfirmed: Bool

    private static let toggleAnimationDuration: CGFloat = 0.2
    private static let checkboxSize: CGFloat = 24
    private static let checkboxCornerRadius: CGFloat = 6

    public init(
        title: String,
        subtitle: String,
        confirmationMessage: String,
        isConfirmed: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.confirmationMessage = confirmationMessage
        self._isConfirmed = isConfirmed
    }

    public var body: some View {
        hRow {
            VStack(alignment: .leading, spacing: .padding16) {
                VStack(alignment: .leading) {
                    hText(title, style: .label)
                        .foregroundColor(hTextColor.Translucent.primary)
                    hText(subtitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .combine)
                checkboxRow
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: Self.toggleAnimationDuration)) {
                isConfirmed.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(backgroundColor)
        )
    }

    private var checkboxRow: some View {
        HStack {
            hRow {
                hText(confirmationMessage)
                    .foregroundColor(confirmationTextColor)
                Spacer()
                checkboxView
            }
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hFillColor.Translucent.negative)
            )
        }
        .colorScheme(.light)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var checkboxView: some View {
        if isConfirmed {
            hCoreUIAssets.checkmark.view
                .foregroundColor(checkmarkColor)
                .frame(width: Self.checkboxSize, height: Self.checkboxSize)
                .background(
                    RoundedRectangle(cornerRadius: Self.checkboxCornerRadius)
                        .fill(hSignalColor.Green.element)
                )
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: Self.checkboxCornerRadius)
                .strokeBorder(hBorderColor.secondary, lineWidth: 2)
                .frame(width: Self.checkboxSize, height: Self.checkboxSize)
                .colorScheme(.light)
                .hUseLightMode
        }
    }

    @hColorBuilder
    private var confirmationTextColor: some hColor {
        hColorScheme(light: hTextColor.Opaque.primary, dark: hTextColor.Opaque.negative)
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

    private var accessibilityLabel: String {
        if isConfirmed {
            return L10n.voiceoverAccepted
        } else {
            return L10n.voiceoverNotAccepted
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isConfirmed = false
    ImportantInformationView(
        title: "Important information",
        subtitle: "Please read and confirm that you understand the terms.",
        confirmationMessage: "I understand",
        isConfirmed: $isConfirmed
    )
}
