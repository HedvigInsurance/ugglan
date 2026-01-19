import SwiftUI
import hCore

public struct ImportantInformationView: View {
    let title: String
    let subtitle: String
    let confirmationMessage: String
    @Binding var isConfirmed: Bool

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
        hSection {
            hRow {
                VStack(spacing: .padding16) {
                    VStack(spacing: .padding16) {
                        VStack(alignment: .leading, spacing: .padding4) {
                            hText(title)
                            hText(subtitle, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                    HStack {
                        hRow {
                            hText(confirmationMessage)
                                .foregroundColor(
                                    hColorScheme(light: hTextColor.Opaque.primary, dark: hTextColor.Opaque.negative)
                                )
                            Spacer()
                            if isConfirmed {
                                HStack {
                                    hCoreUIAssets.checkmark.view
                                        .foregroundColor(
                                            hColorScheme(
                                                light: hTextColor.Opaque.negative,
                                                dark: hTextColor.Opaque.primary
                                            )
                                        )
                                }
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(hSignalColor.Green.element)
                                )
                            } else {
                                Circle()
                                    .fill(hBackgroundColor.clear)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(
                                                hBorderColor.secondary,
                                                lineWidth: 2
                                            )
                                            .animation(.easeInOut, value: UUID())
                                    )
                                    .colorScheme(.light)
                                    .hUseLightMode
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: .cornerRadiusS)
                                .fill(
                                    hFillColor.Translucent.negative
                                )
                        )
                    }
                    .colorScheme(.light)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityAddTraits(.isButton)
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isConfirmed.toggle()
                }
            }
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
