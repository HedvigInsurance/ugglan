import SwiftUI
import hCore
import hCoreUI

public struct VoiceSendButton: View {
    let onTap: () async throws -> Void
    var isEnabled: Bool
    @EnvironmentObject var voiceRecorder: VoiceRecorder

    public init(
        onTap: @escaping () async throws -> Void,
        isEnabled: Bool
    ) {
        self.onTap = onTap
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Button(action: {
            Task {
                voiceRecorder.isSending = true
                try await onTap()
                voiceRecorder.isSending = false
            }
        }) {
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
            .wrapContentForControlButton()
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
        VoiceSendButton(onTap: {}, isEnabled: true)
        VoiceSendButton(onTap: {}, isEnabled: false)
    }
}
