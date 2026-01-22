import SwiftUI
import hCore
import hCoreUI

public struct VoicePlaybackButton: View {
    let isPlaying: Bool
    let onTap: () -> Void

    public init(isPlaying: Bool, onTap: @escaping () -> Void) {
        self.isPlaying = isPlaying
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
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
        .accessibilityLabel(isPlaying ? L10n.a11YPause : L10n.a11YPlay)
        .accessibilityAddTraits(.isButton)
    }

    var buttonImage: some View {
        isPlaying ? hCoreUIAssets.pause.view : hCoreUIAssets.play.view
    }
}

#Preview {
    VStack(spacing: 40) {
        VoicePlaybackButton(isPlaying: false) {}
        VoicePlaybackButton(isPlaying: true) {}
    }
}
