import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let playbackTint: some hColor = hColorScheme(
        light: hTintColorOld.lavenderOne,
        dark: hTextColor.tertiary
    )

    let backgroundColorOld: some hColor = hColorScheme(
        light: hTintColorOld.lavenderTwo,
        dark: hTintColorOld.lavenderOne
    )

    @ViewBuilder var image: some View {
        switch audioPlayer.playbackState {
        case let .playing(paused):
            Image(uiImage: paused ? hCoreUIAssets.play.image : hCoreUIAssets.pause.image)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(hTextColor.primary)
        default:
            Image(uiImage: hCoreUIAssets.play.image)
                .foregroundColor(hTextColor.primary)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if audioPlayer.playbackState == .loading {
                    ActivityIndicator(
                        style: .large,
                        color: hTextColor.primary
                    )
                    .foregroundColor(hTextColor.primary)
                    .transition(.opacity.animation(.easeOut))
                } else {
                    image
                    let waveform = WaveformView(
                        stripeColor: hTextColor.primary,
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
                    .fill(hFillColor.opaqueOne)
            )
            .onTapGesture {
                audioPlayer.togglePlaying()
            }
        }
    }
}

struct TrackPlayer_Previews: PreviewProvider {

    static var previews: some View {
        let audioPlayer = AudioPlayer(url: nil)
        TrackPlayer(audioPlayer: audioPlayer)
    }
}
