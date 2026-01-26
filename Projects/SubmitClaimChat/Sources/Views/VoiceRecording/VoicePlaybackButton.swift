import SwiftUI
import hCore
import hCoreUI

public struct VoicePlaybackButton: View {
    @EnvironmentObject var voiceRecorder: VoiceRecorder

    public var body: some View {
        Button(action: {
            ImpactGenerator.soft()
            voiceRecorder.togglePlayback()
        }) {
            VStack(spacing: .padding4) {
                ZStack {
                    Circle()
                        .fill(hFillColor.Opaque.primary)
                        .frame(width: 32, height: 32)

                    buttonImage
                        .foregroundColor(hFillColor.Opaque.negative)
                }

                hText(L10n.audioRecorderListen, style: .label)
            }
            .wrapContentForControlButton()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(voiceRecorder.isPlaying ? L10n.a11YPause : L10n.a11YPlay)
        .accessibilityAddTraits(.isButton)
    }

    var buttonImage: some View {
        voiceRecorder.isPlaying ? hCoreUIAssets.pause.view : hCoreUIAssets.play.view
    }
}
