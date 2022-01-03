import AVFoundation
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
        HStack(spacing: 16) {
            image

            WaveformView()
                .frame(maxWidth: .infinity)
                .overlay(
                    OverlayView(audioPlayer: audioPlayer)
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

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColor: some hColor = hTintColor.lavenderOne

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(staplesMaskColor)
                    .frame(width: geometry.size.width * audioPlayer.progress)
            }
        }
    }
}

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    internal init(
        url: URL,
        isPlaying: Bool = false
    ) {
        self.url = url
        self.isPlaying = isPlaying
    }

    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()

    var audioPlayer: AVPlayer?

    let playerTimer = Timer.publish(every: 1 / 30, on: .main, in: .common)
        .autoconnect()

    let url: URL

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

        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)

        audioPlayer?
            .addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 1),
                queue: .main,
                using: { [weak self] time in
                    guard let self = self else { return }
                    if let item = self.audioPlayer?.currentItem, item.status == .readyToPlay {
                        let duration = CMTimeGetSeconds(item.duration)
                        let timeInFloat = CMTimeGetSeconds(time)
                        self.progress = timeInFloat / duration

                    }
                }
            )

        audioPlayer?.actionAtItemEnd = .pause
        audioPlayer?.play()
        isPlaying = true
    }

    private func stopPlaying() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
