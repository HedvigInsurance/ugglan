import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let playbackTint: some hColor = hColorScheme(
        light: hTintColor.lavenderOne,
        dark: hLabelColor.tertiary
    )

    let loadingColor: some hColor = hColorScheme(
        light: hLabelColor.link,
        dark: hLabelColor.primary
    )

    @ViewBuilder var image: some View {
        switch audioPlayer.playbackState {
        case let .playing(paused):
            Image(uiImage: paused ? hCoreUIAssets.play.image : hCoreUIAssets.pause.image)
                .foregroundColor(playbackTint)
        default:
            Image(uiImage: hCoreUIAssets.play.image)
                .foregroundColor(playbackTint)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if audioPlayer.playbackState == .loading {
                    ActivityIndicator(style: .large)
                        .foregroundColor(loadingColor)
                } else {
                    image

                    let waveform = WaveformView(
                        stripeColor: playbackTint,
                        sampleHeights: audioPlayer.sampleHeights
                    ).frame(maxWidth: .infinity)
                    waveform
                        .overlay(
                            OverlayView(audioPlayer: audioPlayer).mask(waveform)
                        )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(hColorScheme(light: hTintColor.lavenderTwo, dark: hTintColor.lavenderOne))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    audioPlayer.togglePlaying()
                }
            }

            hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                .foregroundColor(hLabelColor.secondary)
        }
    }
}
