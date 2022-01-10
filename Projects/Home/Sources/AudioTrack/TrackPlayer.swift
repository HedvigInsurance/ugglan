import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    @ViewBuilder var image: some View {
        Image(uiImage: audioPlayer.isPlaying ? hCoreUIAssets.pause.image : hCoreUIAssets.play.image)
            .foregroundColor(hLabelColor.link)
    }

    var body: some View {
        HStack(spacing: 16) {
            image

            WaveformView(stripeColor: hLabelColor.link)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hColorScheme(light: hTintColor.lavenderTwo, dark: hTintColor.lavenderOne))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            OverlayView(audioPlayer: audioPlayer)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                audioPlayer.togglePlaying()
            }
        }
    }
}
