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
        switch audioPlayer.playbackState {
        case .error:
            PlaybackFailedView()
        case .loading:
            VStack(alignment: .leading, spacing: 8) {
                PlaybackView {
                    ActivityIndicator(style: .large)
                        .foregroundColor(loadingColor)
                }
                
                hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                    .foregroundColor(hLabelColor.secondary)
            }
        default:
            VStack(alignment: .leading, spacing: 8) {
                PlaybackView {
                    image

                    let waveform = WaveformView(stripeColor: playbackTint)
                        .frame(maxWidth: .infinity)
                    waveform
                        .overlay(
                            OverlayView(audioPlayer: audioPlayer).mask(waveform)
                        )
                }
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
}
