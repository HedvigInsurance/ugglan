import SwiftUI
import hCore
import hCoreUI

public struct VoiceStartOverButton: View {
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
                            .fill(hSurfaceColor.Translucent.secondary)
                            .frame(width: 32, height: 32)

                        hCoreUIAssets.reload.view
                            .foregroundColor(imageColor)
                    }

                    hText(L10n.embarkRecordAgain, style: .label)
                        .foregroundColor(textColor)
                }
                .padding(.vertical, .padding8)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.embarkRecordAgain)
        .accessibilityAddTraits(.isButton)
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
    VoiceStartOverButton {}
}
