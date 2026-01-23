import SwiftUI
import hCore
import hCoreUI

public struct VoiceSendButton: View {
    let onTap: () async throws -> Void
    @EnvironmentObject var voiceRecorder: VoiceRecorder

    public init(
        onTap: @escaping () async throws -> Void,
    ) {
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: {
            Task {
                voiceRecorder.isSending = true
                try await onTap()
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
        .disabled(!voiceRecorder.hasRecording)
        .accessibilityLabel(L10n.chatUploadPresend)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(voiceRecorder.hasRecording ? "" : L10n.claimsStartRecordingLabel)
        .animation(.defaultSpring, value: voiceRecorder.hasRecording)
    }

    @hColorBuilder
    private var circleColor: some hColor {
        if voiceRecorder.hasRecording {
            hSignalColor.Blue.element
        } else {
            hSurfaceColor.Translucent.secondary
        }
    }

    @hColorBuilder
    private var iconColor: some hColor {
        if voiceRecorder.hasRecording {
            hFillColor.Opaque.white
        } else {
            hFillColor.Opaque.tertiary
        }
    }

    @hColorBuilder
    private var textColor: some hColor {
        if voiceRecorder.hasRecording {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.tertiary
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceSendButton(onTap: {})
            .environmentObject(VoiceRecorder())
        VoiceSendButton(onTap: {})
            .environmentObject(VoiceRecorder())
    }
}
