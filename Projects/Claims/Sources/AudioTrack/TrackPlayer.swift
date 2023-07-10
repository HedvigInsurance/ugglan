import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Environment(\.hWithoutFootnote) var hWithoutFootnote

    let playbackTint: some hColor = hColorScheme(
        light: hTintColor.lavenderOne,
        dark: hLabelColor.tertiary
    )

    let backgroundColorOld: some hColor = hColorScheme(
        light: hTintColor.lavenderTwo,
        dark: hTintColor.lavenderOne
    )

    @ViewBuilder var image: some View {
        switch audioPlayer.playbackState {
        case let .playing(paused):
            Image(uiImage: paused ? hCoreUIAssets.play.image : hCoreUIAssets.pause.image)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(hTextColorNew.primary)
        default:
            Image(uiImage: hCoreUIAssets.play.image)
                .foregroundColor(hTextColorNew.primary)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if audioPlayer.playbackState == .loading {
                    ActivityIndicator(
                        style: .large,
                        color: hLabelColor.primary
                    )
                    .foregroundColor(hLabelColor.primary)
                    .transition(.opacity.animation(.easeOut))
                } else {
                    image
                    let waveform = WaveformView(
                        stripeColor: hTextColorNew.primary,
                        sampleHeights: audioPlayer.sampleHeights
                    )
                    .frame(maxWidth: .infinity)
                    waveform
                        .padding(.top, 6)
                        .overlay(
                            OverlayView(audioPlayer: audioPlayer)
                                .mask(waveform)
                                .padding(.top, 6)
                        )
                        .transition(.opacity.animation(.easeOut))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(hFillColorNew.opaqueOne)
            )
            .onTapGesture {
                audioPlayer.togglePlaying()
            }

            if !hWithoutFootnote {
                hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                    .foregroundColor(hTextColorNew.secondary)
            }
        }
    }
}

private struct EnvironmentHWithoutFootnote: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hWithoutFootnote: Bool {
        get { self[EnvironmentHWithoutFootnote.self] }
        set { self[EnvironmentHWithoutFootnote.self] = newValue }
    }
}

extension View {
    public var hWithoutFootnote: some View {
        self.environment(\.hWithoutFootnote, true)
    }
}

struct TrackPlayer_Previews: PreviewProvider {

    static var previews: some View {
        let audioPlayer = AudioPlayer(url: nil)
        TrackPlayer(audioPlayer: audioPlayer)
            .hWithoutFootnote
    }
}
