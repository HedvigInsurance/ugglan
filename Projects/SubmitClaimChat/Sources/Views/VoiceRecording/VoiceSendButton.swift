import SwiftUI
import hCore
import hCoreUI

public struct VoiceSendButton: View {
    let onTap: () -> Void
    @Environment(\.isEnabled) var isEnabled

    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            hSection {
                VStack(spacing: .padding4) {
                    ZStack {
                        Circle()
                            .fill(circleColor)
                            .frame(width: 32, height: 32)

                        hCoreUIAssets.arrowUp.view
                            .foregroundColor(iconColor)
                    }

                    hText(L10n.chatUploadPresend, style: .label)
                        .foregroundColor(textColor)
                }
                .padding(.vertical, .padding8)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.chatUploadPresend)
        .accessibilityAddTraits(.isButton)
    }

    @hColorBuilder
    private var circleColor: some hColor {
        if isEnabled {
            hSignalColor.Blue.element
        } else {
            hSurfaceColor.Translucent.secondary
        }
    }

    @hColorBuilder
    private var iconColor: some hColor {
        if isEnabled {
            hFillColor.Opaque.white
        } else {
            hFillColor.Opaque.tertiary
        }
    }

    @hColorBuilder
    private var textColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.tertiary
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceSendButton {}
        VoiceSendButton {}
            .disabled(true)
    }
}
