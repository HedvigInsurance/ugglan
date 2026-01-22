import SwiftUI
import hCore
import hCoreUI

public struct VoiceStartOverButton: View {
    let onTap: () -> Void
    var isEnabled: Bool

    public init(
        onTap: @escaping () -> Void,
        isEnabled: Bool
    ) {
        self.onTap = onTap
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: .padding4) {
                ZStack {
                    Circle()
                        .fill(hSurfaceColor.Translucent.secondary)
                        .frame(width: 32, height: 32)

                    hCoreUIAssets.reload.view
                        .foregroundColor(imageColor)
                }

                hText(L10n.embarkRecordAgain, style: .label)
                    .foregroundColor(textColor)
            }
            .wrapContentForControlButton()
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(L10n.embarkRecordAgain)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isEnabled ? "" : L10n.claimsStartRecordingLabel)
    }

    @hColorBuilder
    private var imageColor: some hColor {
        if isEnabled {
            hFillColor.Opaque.primary
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
    VoiceStartOverButton(onTap: {}, isEnabled: true)
}

extension View {
    func wrapContentForControlButton() -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
        .padding(.vertical, .padding8)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusL)
                .fill(hSurfaceColor.Opaque.primary)
        }
    }
}
