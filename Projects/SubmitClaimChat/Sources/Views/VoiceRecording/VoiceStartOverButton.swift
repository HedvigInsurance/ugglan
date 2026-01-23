import SwiftUI
import hCore
import hCoreUI

public struct VoiceStartOverButton: View {
    @EnvironmentObject var voiceRecorder: VoiceRecorder
    public var body: some View {
        Button(action: {
            voiceRecorder.startOver()
        }) {
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
        .disabled(!voiceRecorder.hasRecording)
        .accessibilityLabel(L10n.embarkRecordAgain)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(voiceRecorder.hasRecording ? "" : L10n.claimsStartRecordingLabel)
        .animation(.defaultSpring, value: voiceRecorder.hasRecording)
    }

    @hColorBuilder
    private var imageColor: some hColor {
        if voiceRecorder.hasRecording {
            hFillColor.Opaque.primary
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
    VoiceStartOverButton()
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
