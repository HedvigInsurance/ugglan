import AVFoundation
import Combine
import Foundation

class AudioPlayer: NSObject, ObservableObject {
    internal init(
        url: URL,
        isPlaying: Bool = false
    ) {
        self.url = url
        self.isPlaying = isPlaying
    }

    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    var audioPlayer: AVPlayer?
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
        if audioPlayer == nil {
            startPlaying()
        } else if audioPlayer?.timeControlStatus == .paused {
            audioPlayer?.play()
            isPlaying = true
        } else if audioPlayer?.timeControlStatus == .playing {
            audioPlayer?.pause()
            isPlaying = false
        }
    }

    func addAudioPlayerNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
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

        addAudioPlayerNotificationObserver()

        audioPlayer?
            .addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 50),
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

    @objc func playerDidFinishPlaying() {
        isPlaying = false
        audioPlayer = nil
    }
}
