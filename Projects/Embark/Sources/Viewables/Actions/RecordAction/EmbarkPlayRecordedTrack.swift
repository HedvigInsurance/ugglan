import AVFAudio
import Combine
import Foundation
import SwiftUI
import Swifter
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    @ViewBuilder var image: some View {
        if audioPlayer.isPlaying {
            Image(uiImage: hCoreUIAssets.pause.image)
        } else {
            Image(uiImage: hCoreUIAssets.play.image)
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            image.tint(hLabelColor.primary)
            let staples = Staples(audioPlayer: audioPlayer)
                .frame(height: 100)
                .clipped()
            staples
                .overlay(
                    OverlayView(audioPlayer: audioPlayer).mask(staples)
                )

        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(hBackgroundColor.secondary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            audioPlayer.togglePlaying()
        }
    }
}

struct Staple: View {
    let staplesDefaultColor: some hColor = hColorScheme.init(light: hGrayscaleColor.one, dark: hGrayscaleColor.two)
    
    var index: Int
    var height: CGFloat
    var value: CGFloat
    var range: Range<CGFloat>

    var heightRatio: CGFloat {
        max(value - range.lowerBound / magnitude(of: range), 0.01)
    }

    var body: some View {
        Capsule()
            .fill(staplesDefaultColor)
            .frame(width: 3, height: height)
            .scaleEffect(x: 1, y: 0.4 + heightRatio, anchor: .center)
    }
    
    func magnitude(of range: Range<CGFloat>) -> CGFloat {
        return range.upperBound - range.lowerBound
    }
}

struct Staples: View {
    @ObservedObject var audioPlayer: AudioPlayer
    
    var body: some View {
        let sample = audioPlayer.recording.sample
        let sampleRange = audioPlayer.recording.range
        
        GeometryReader { geometry in
            HStack(alignment: .center) {
                ForEach(
                    Array(trim(sample: sample, availableWidth: geometry.size.width).enumerated()), id: \.offset
                ) { index, sample in
                    Spacer()
                    Staple(
                        index: index,
                        height: geometry.size.height,
                        value: sample,
                        range: sampleRange
                    ).animation(.ripple(index: index))
                }
            }.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func trim(sample: [CGFloat], availableWidth: CGFloat) -> [CGFloat] {
        let trimmed = sample
        
        let count = Double(trimmed.count)

        let maxStaples = Double(availableWidth / 4)

        guard count > maxStaples else { return trimmed }
        
        let roundUp = ceil(Double(trimmed.count) / maxStaples)

        let chunkSize = max(Int(roundUp), 2)

        return trimmed.chunked(into: chunkSize)
            .compactMap {
                return $0.reduce(0, +) / CGFloat($0.count)
            }
    }
}

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
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
