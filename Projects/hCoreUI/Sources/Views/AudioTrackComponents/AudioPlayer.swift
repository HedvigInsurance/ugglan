import AVFoundation
import Combine
import Foundation
import SwiftUI
import hCore

@MainActor
public class AudioPlayer: NSObject, @preconcurrency ObservableObject {
    public init(
        url: URL?
    ) {
        self.url = url
        sampleHeights = generateGaussianHeights()
    }

    public let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    var audioPlayer: AVPlayer?
    let sampleHeights: [Int]
    var observerStatus: NSKeyValueObservation?

    public enum PlaybackState: Equatable {
        case idle
        case playing(paused: Bool)
        case error(message: String)
        case loading
        case finished
    }

    public var playbackState: PlaybackState = .idle {
        didSet {
            switch playbackState {
            case .idle:
                break
            case let .playing(paused):
                if paused, audioPlayer?.rate != 0 {
                    audioPlayer?.pause()
                }
            case .error:
                break
            case .loading:
                break
            case .finished:
                break
            }
            withAnimation {
                objectWillChange.send(self)
            }
        }
    }

    private(set) var progress: Double = 0 {
        didSet {
            withAnimation {
                objectWillChange.send(self)
            }
        }
    }

    public var url: URL? {
        didSet {
            withAnimation {
                objectWillChange.send(self)
            }
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

    func setProgress(to progress: Double) {
        if let duration = audioPlayer?.currentItem?.duration {
            let time = duration.seconds * progress
            audioPlayer?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: 1000))
            self.progress = progress
        } else {
            startPlaying()
        }
    }

    private func startPlaying() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try session.setActive(true)
        } catch {
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
                        Task { @MainActor in
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
                    }
                )

            // in your method where you setup your player item
            observerStatus = playerItem.observe(
                \.status,
                changeHandler: { [weak self] item, _ in
                    debugPrint("status: \(item.status.rawValue)")
                    if item.status == .failed {
                        Task { @MainActor in
                            self?.playbackState = .error(message: "Unknown playback error")
                        }
                    }
                }
            )
        }

        audioPlayer?.actionAtItemEnd = .pause
        audioPlayer?.play()
    }

    override public func observeValue(
        forKeyPath keyPath: String?,
        of _: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context _: UnsafeMutableRawPointer?
    ) {
        if keyPath == "timeControlStatus",
            let change = change,
            let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
            let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int
        {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            Task { @MainActor in
                if newStatus == .playing {
                    self.playbackState = .playing(paused: false)
                } else if newStatus == .paused, playbackState != .finished {
                    self.playbackState = .playing(paused: true)
                }
                if newStatus != oldStatus, newStatus != .playing, newStatus != .paused {
                    self.playbackState = .loading
                }
            }
        }
    }

    @objc func playerDidFinishPlaying() {
        playbackState = .finished
    }
}
