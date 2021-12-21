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
        Image(uiImage: audioPlayer.isPlaying ? hCoreUIAssets.pause.image : hCoreUIAssets.play.image)
            .foregroundColor(hLabelColor.link)
    }

    var body: some View {
        HStack(alignment: .center) {
            image
            let staples = Staples(audioPlayer: audioPlayer)
                .frame(height: 50)
                .clipped()
            staples
                .overlay(
                    OverlayView(audioPlayer: audioPlayer).mask(staples)
                )

        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
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

struct Staple: View {
    let staplesDefaultColor: some hColor = hColorScheme(light: hTintColor.lavenderOne, dark: hTintColor.lavenderTwo)

    var index: Int
    var height: CGFloat
    var value: CGFloat
    var range: Range<CGFloat>

    var heightRatio: CGFloat {
        max((value - range.lowerBound) / magnitude(of: range), 0.05)
    }

    var body: some View {
        Capsule()
            .fill(staplesDefaultColor)
            .frame(width: 2, height: height)
            .scaleEffect(x: 1, y: heightRatio, anchor: .center)
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
                    Array(trim(sample: sample, availableWidth: geometry.size.width).enumerated()),
                    id: \.offset
                ) { index, sampleHeight in
                    Spacer()
                    Staple(
                        index: index,
                        height: geometry.size.height,
                        value: sampleHeight,
                        range: sampleRange
                    )
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func trim(sample: [CGFloat], availableWidth: CGFloat) -> [CGFloat] {
        let trimmed = sample

        let count = Double(trimmed.count)

        let maxStaples = Double(availableWidth / 2)

        guard count > maxStaples else { return trimmed }

        let roundUp = ceil(Double(trimmed.count) / maxStaples)

        let chunkSize = max(Int(roundUp), 2)

        return trimmed.chunked(into: chunkSize)
            .compactMap {
                return $0.reduce(0, +) / CGFloat($0.count)
            }
    }
}

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColor: some hColor = hTintColor.lavenderOne

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

struct Recording {
    var url: URL
    var created: Date
    var sample: [CGFloat]
    var max: CGFloat {
        return sample.max() ?? 1.0
    }
    var range: Range<CGFloat> {
        guard sample.count > 0 else { return 0..<0 }
        return sample.min()!..<sample.max()!
    }
}

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    internal init(
        recording: Recording,
        isPlaying: Bool = false
    ) {
        self.recording = recording
        self.isPlaying = isPlaying
    }

    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()

    var audioPlayer: AVAudioPlayer?

    let playerTimer = Timer.publish(every: 1 / 30, on: .main, in: .common)
        .autoconnect()

    let recording: Recording

    private(set) var isPlaying: Bool = false {
        didSet {
            objectWillChange.send(self)
        }
    }

    private(set) var progress: Double = 0 {
        didSet {
            objectWillChange.send(self)
        }
    }

    func togglePlaying() {
        isPlaying ? stopPlaying() : startPlaying()
    }

    private func startPlaying() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try session.setActive(true)
        } catch {
            print("Playing over the device's speakers failed")
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.play()
            audioPlayer?.delegate = self
            isPlaying = true
        } catch {
            print("Playback failed.")
        }
    }

    func refreshPlayer() {
        guard let elapsedTime = audioPlayer?.currentTime, let maxTime = audioPlayer?.duration else { return }

        self.progress = elapsedTime / maxTime
    }

    private func stopPlaying() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
