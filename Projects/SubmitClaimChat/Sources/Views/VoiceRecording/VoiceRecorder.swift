import AVFAudio
import Combine
import Foundation
import SwiftUI
import hCore

@MainActor
public final class VoiceRecorder: ObservableObject {
    public static let audioFileExtension = "m4a"

    // MARK: - Published State
    @Published public private(set) var recordingState: RecordingState = .idle
    @Published public private(set) var currentTime: TimeInterval?
    @Published public private(set) var audioLevels: [CGFloat] = []
    @Published public private(set) var recordedFileURL: URL?
    @Published public var error: VoiceRecorderError?

    public var isRecording: Bool { recordingState == .recording }
    @Published public var isSending: Bool = false
    @Published public var isCountingDown: Bool = false

    public var hasRecording: Bool { recordedFileURL != nil }
    public var isPlaying: Bool { recordingState == .playing }

    public var progress: Double {
        guard let player, player.duration > 0 else { return 0 }
        return player.currentTime / player.duration
    }

    // MARK: - Private Properties
    private let filePath: URL
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var meteringTimer: Timer?
    private var recordingStartTime: Date?
    private var recentPeaks: [CGFloat] = []
    private let peakWindowSize = 30  // Track peaks over last 30 samples

    // MARK: - Types
    public enum RecordingState: Equatable {
        case idle
        case recording
        case recorded
        case playing
    }

    public enum VoiceRecorderError: Error, LocalizedError {
        case permissionDenied
        case recordingFailed
        case playbackFailed
        case sendingFailed

        public var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return L10n.voiceoverAudioMicPermissionDenied
            case .recordingFailed:
                return L10n.voiceoverAudioRecordingFailed
            case .playbackFailed:
                return L10n.voiceoverAuidoPlaybackFailed
            case .sendingFailed:
                return L10n.generalTryAgain
            }
        }

        public var title: String? {
            switch self {
            case .sendingFailed:
                return L10n.voiceoverAudioSendingFailed
            default:
                return nil
            }
        }
    }

    // MARK: - Initialization
    public init(filePath: URL) {
        self.filePath = filePath
    }

    public convenience init() {
        let tmpDir = FileManager.default.temporaryDirectory
        let path =
            tmpDir
            .appendingPathComponent("claims", isDirectory: true)
            .appendingPathComponent("voice-recording-\(UUID().uuidString)")
            .appendingPathExtension(VoiceRecorder.audioFileExtension)
        self.init(filePath: path)
    }

    // MARK: - Public Methods
    public func startRecording() async -> Bool {
        error = nil
        let granted = await requestMicrophonePermission()
        guard granted else {
            error = .permissionDenied
            return false
        }

        do {
            try configureAudioSession()
            try prepareRecorder()
            recorder?.record()
            recordingState = .recording
            recordingStartTime = Date()
            startTimers()
            return true
        } catch {
            self.error = .recordingFailed
            return false
        }
    }

    public func askForPermissionIfNeeded() async throws {
        await requestMicrophonePermission()
        let status = microphonePermissionStatus()
        switch status {
        case .undetermined:
            error = .permissionDenied
            throw VoiceRecorderError.permissionDenied
        case .denied:
            error = .permissionDenied
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                throw VoiceRecorderError.permissionDenied
            }
            Dependencies.urlOpener.open(settingsUrl)
            throw VoiceRecorderError.permissionDenied
        case .granted:
            break
        }
    }

    public func stopRecording() {
        recorder?.stop()
        stopTimers()

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }

        if FileManager.default.fileExists(atPath: filePath.path) {
            recordedFileURL = filePath
            recordingState = .recorded
            // Prepare player early to reduce delay when user clicks play
            preparePlayer()
        } else {
            recordingState = .idle
        }
    }

    public func toggleRecording() async {
        if isRecording {
            stopRecording()
        } else {
            _ = await startRecording()
        }
    }

    public func startPlayback() {
        // If player isn't ready, prepare it first
        if player == nil {
            preparePlayer()
        }

        guard let player else {
            error = .playbackFailed
            return
        }

        player.play()
        recordingState = .playing
        startPlaybackTimer()
    }

    private func preparePlayer() {
        guard let url = recordedFileURL else {
            return
        }

        do {
            try configureAudioSession()
            player = try AVAudioPlayer(contentsOf: url)
            player?.isMeteringEnabled = true
            player?.prepareToPlay()
        } catch {
            self.error = .playbackFailed
        }
    }

    public func pausePlayback() {
        player?.pause()
        stopTimers()
        recordingState = .recorded
    }

    public func stopPlayback() {
        player?.stop()
        player = nil
        stopTimers()
        recordingState = .recorded
        currentTime = nil
    }

    public func togglePlayback() {
        error = nil
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    public func setProgress(to progress: Double) {
        // Ensure player is prepared before seeking
        if player == nil {
            preparePlayer()
        }

        guard let player = self.player else { return }

        let newTime = player.duration * progress
        player.currentTime = newTime
        currentTime = newTime
        // Ensure player is ready for playback after seeking
        player.prepareToPlay()
    }

    public func startOver() {
        error = nil
        stopTimers()
        recorder?.stop()
        recorder = nil
        player?.stop()
        player = nil

        if let url = recordedFileURL, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }

        recordedFileURL = nil
        currentTime = nil
        audioLevels = []
        recentPeaks = []
        recordingState = .idle
        error = nil
    }

    public func reset() {
        startOver()
    }

    // MARK: - Private Methods
    @discardableResult
    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance()
                    .requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
            }
        }
    }

    private func microphonePermissionStatus() -> PermissionStatus {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .undetermined:
                return .undetermined
            case .denied:
                return .denied
            case .granted:
                return .granted
            @unknown default:
                return .denied
            }
        } else {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined:
                return .undetermined
            case .denied:
                return .denied
            case .granted:
                return .granted
            @unknown default:
                return .denied
            }
        }
    }

    private enum PermissionStatus {
        case undetermined
        case denied
        case granted
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [.defaultToSpeaker, .allowBluetooth, .duckOthers]
        )
        try session.setActive(true)
    }

    private func prepareRecorder() throws {
        // Ensure directory exists
        let directory = filePath.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Remove existing file
        if FileManager.default.fileExists(atPath: filePath.path) {
            try FileManager.default.removeItem(at: filePath)
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        recorder = try AVAudioRecorder(url: filePath, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
    }

    private func startTimers() {
        // Timer for updating current time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let startTime = self.recordingStartTime else { return }
                self.currentTime = Date().timeIntervalSince(startTime)
            }
        }

        // Timer for metering audio levels
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAudioLevels()
            }
        }
    }

    private func startPlaybackTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime

                // Pause when playback finishes (keep player alive for seeking)
                if !player.isPlaying {
                    self.pausePlayback()
                }
            }
        }
    }

    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        meteringTimer?.invalidate()
        meteringTimer = nil
    }

    private func updateAudioLevels() {
        guard let recorder, isRecording else { return }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)

        // Initial normalization: power ranges from -160 to 0
        let normalizedPower = max(0, (power + 50) / 50)
        let rawLevel = CGFloat(pow(10, normalizedPower) - 1) / 9  // Scale to 0...1

        // Track recent peaks for adaptive normalization
        recentPeaks.append(rawLevel)
        if recentPeaks.count > peakWindowSize {
            recentPeaks.removeFirst()
        }

        // Calculate adaptive scale based on recent peak
        let recentPeak = recentPeaks.max() ?? 0.3
        let adaptiveScale = recentPeak > 0.2 ? (0.85 / recentPeak) : 1.0  // Target using 85% of range

        // Apply adaptive scaling to make better use of the visual range
        let adaptedLevel = min(1.0, rawLevel * adaptiveScale)

        audioLevels.append(adaptedLevel)
    }

    @MainActor
    deinit {
        timer?.invalidate()
        meteringTimer?.invalidate()
        if let url = recordedFileURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Time Formatting
extension VoiceRecorder {
    public var formattedTime: String? {
        guard let currentTime else { return nil }
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    public var formattedTimeMinutes: String? {
        guard let currentTime else { return nil }
        let minutes = Int(currentTime) / 60
        return String(format: "%02d", minutes)
    }
    public var formattedTimeSeconds: String? {
        guard let currentTime else { return nil }
        let seconds = Int(currentTime) % 60
        return String(format: "%02d", seconds)
    }
}
