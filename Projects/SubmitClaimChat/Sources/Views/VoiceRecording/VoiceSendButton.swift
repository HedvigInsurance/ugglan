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

    private var isEnabled: Bool { voiceRecorder.hasRecording && !voiceRecorder.isSending }

    public var body: some View {
        Button(action: {
            ImpactGenerator.soft()
            Task {
                voiceRecorder.error = nil
                voiceRecorder.isSending = true
                voiceRecorder.stopPlayback()
                do {
                    try await onTap()
                } catch {
                    voiceRecorder.isSending = false
                    voiceRecorder.error = .sendingFailed
                }
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
                .opacity(voiceRecorder.isSending ? 0.4 : 1)

                hText(
                    voiceRecorder.isSending ? L10n.claimsVoiceRecordingSending : L10n.chatUploadPresend,
                    style: .label
                )
                .foregroundColor(textColor)
            }
            .wrapContentForControlButton()
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(L10n.chatUploadPresend)
        .accessibilityAddTraits(.isButton)
        .animation(.defaultSpring, value: voiceRecorder.hasRecording)
        .animation(.defaultSpring, value: voiceRecorder.isSending)
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
        if isEnabled {
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
