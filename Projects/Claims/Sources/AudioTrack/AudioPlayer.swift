import AVFoundation
import Combine
import Foundation
import hCore

class AudioPlayer: NSObject, ObservableObject {
    internal init(
        url: URL?
    ) {
        self.url = url
        self.sampleHeights = generateGaussianHeights()
    }

    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    var audioPlayer: AVPlayer?
    let sampleHeights: [Int]

    enum PlaybackState: Equatable {
        case idle
        case playing(paused: Bool)
        case error(message: String)
        case loading
        case finished
    }

    private(set) var playbackState: PlaybackState = .idle {
        didSet {
            objectWillChange.send(self)
        }
    }

    private(set) var progress: Double = 0 {
        didSet {
            objectWillChange.send(self)
        }
    }

    var url: URL? {
        didSet {
            objectWillChange.send(self)
        }
    }

    func togglePlaying() {
        switch playbackState {
        case .idle, .error, .finished:
            startPlaying()
        case let .playing(paused):
            paused ? audioPlayer?.play() : audioPlayer?.pause()
        case .loading:
            break
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

        audioPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }

    private func startPlaying() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try session.setActive(true)
        } catch {
            //            self.playbackState = .error(message: "Playing over the device's speakers failed")
            try? session.setCategory(.playback)
            try? session.setActive(true)
        }
        if let url {
            let playerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: playerItem)
            addAudioPlayerNotificationObserver()

            audioPlayer?
                .addPeriodicTimeObserver(
                    forInterval: CMTime(value: 1, timescale: 50),
                    queue: .main,
                    using: { [weak self] time in
                        guard let self = self, let item = self.audioPlayer?.currentItem else { return }

                        switch item.status {
                        case .readyToPlay:
                            let duration = CMTimeGetSeconds(item.duration)
                            let timeInFloat = CMTimeGetSeconds(time)
                            self.progress = timeInFloat / duration
                        case .failed:
                            break
                        case .unknown:
                            break
                        default:
                            self.playbackState = .error(message: "Unknown playback error")
                        }
                    }
                )

            audioPlayer?.actionAtItemEnd = .pause
            audioPlayer?.play()
        }
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "timeControlStatus",
            let change = change,
            let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
            let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int
        {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)

            if newStatus == .playing {
                self.playbackState = .playing(paused: false)
            } else if newStatus == .paused && playbackState != .finished {
                self.playbackState = .playing(paused: true)
            }

            if newStatus != oldStatus, newStatus != .playing && newStatus != .paused {
                DispatchQueue.main.async { [weak self] in
                    self?.playbackState = .loading
                }
            }
        }
    }

    @objc func playerDidFinishPlaying() {
        self.playbackState = .finished
    }
}
