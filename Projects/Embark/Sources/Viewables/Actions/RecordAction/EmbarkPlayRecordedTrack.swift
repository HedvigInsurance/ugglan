import AVFAudio
import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(hBackgroundColor.secondary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            HStack {
                SwiftUI.Button(action: {
                    audioPlayer.togglePlaying()
                }) {
                    if audioPlayer.isPlaying {
                        Image(uiImage: hCoreUIAssets.pause.image)
                    } else {
                        Image(uiImage: hCoreUIAssets.play.image)
                    }
                }.tint(hLabelColor.primary)
                Spacer()
                ScrollView(.horizontal) {
                    let staples = Staples(audioPlayer: audioPlayer)
                    staples
                        .overlay(
                            OverlayView(audioPlayer: audioPlayer).mask(staples)
                        )
                }
            }
            .padding(20)
        }
    }
}

struct Staples: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesDefaultColor: some hColor = hColorScheme.init(light: hGrayscaleColor.one, dark: hGrayscaleColor.two)

    struct Staple: Identifiable {
        var id = UUID()
        var scale: CGFloat
    }

    var body: some View {
        HStack(alignment: .center, spacing: 2.5) {
            ForEach(audioPlayer.recording.sample.map { Staple(scale: $0) }) { bar in
                RoundedRectangle(cornerRadius: 1)
                    .fill(staplesDefaultColor)
                    .frame(
                        width: 1.85,
                        height: calculateHeightForBar(maxValue: audioPlayer.recording.max, scale: bar.scale)
                    )
                    .animation(.easeInOut)
            }
        }
    }

    func calculateHeightForBar(maxValue: CGFloat, scale: CGFloat) -> CGFloat {
        let maxHeight = CGFloat(60)
        let minHeight = CGFloat(5)

        let height = scale / maxValue * maxHeight

        return max(height, minHeight)
    }
}

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColor: some hColor = hColorScheme.init(light: hLabelColor.primary, dark: hTintColor.lavenderOne)

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
