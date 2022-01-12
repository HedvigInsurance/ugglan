import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let playbackTint: some hColor = hColorScheme(light: hTintColor.lavenderOne, dark: hTintColor.lavenderTwo.inverted)

    @ViewBuilder var image: some View {
        Image(uiImage: audioPlayer.isPlaying ? hCoreUIAssets.pause.image : hCoreUIAssets.play.image)
            .foregroundColor(playbackTint)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            image

            let waveform = WaveformView(stripeColor: playbackTint)
                .frame(maxWidth: .infinity)
            waveform
                .overlay(
                    OverlayView(audioPlayer: audioPlayer).mask(waveform)
                )
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }
}
