import AVFAudio
import Combine
import Foundation
import SwiftUI
import Swifter
import hAnalytics
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    var onPlay: () -> Void

    @ViewBuilder var image: some View {
        if audioPlayer.isPlaying {
            Image(uiImage: hCoreUIAssets.pause.image)
        } else {
            Image(uiImage: hCoreUIAssets.play.image)
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            image.tint(hTextColor.primary)
            let waveform = WaveformView(
                maxStripeHeight: 70,
                stripeColor: hColorScheme.init(light: hBorderColor.opaqueOne, dark: hTextColor.tertiary),
                sampleHeights: audioPlayer.audioSampleHeights
            )
            .frame(height: 100)
            .clipped()
            waveform
                .overlay(
                    OverlayView(audioPlayer: audioPlayer).mask(waveform)
                )

        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hBackgroundColor.primary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            onPlay()

            withAnimation(.spring()) {
                audioPlayer.togglePlaying()
            }
        }
    }
}

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColor: some hColor = hColorScheme.init(
        light: hTextColor.primary,
        dark: hHighlightColor.purpleFillThree
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(staplesMaskColor)
                    .frame(width: geometry.size.width * audioPlayer.progress)
                    .onReceive(audioPlayer.playerTimer) { input in
                        guard audioPlayer.isPlaying else { return }
                        audioPlayer.refreshPlayer()
                    }
            }
        }
    }
}
