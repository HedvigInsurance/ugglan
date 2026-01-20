import AVFAudio
import Combine
import Foundation
import SwiftUI

@MainActor
public final class VoiceRecorder: ObservableObject {
    public static let audioFileExtension = "m4a"

    // MARK: - Published State
    @Published public private(set) var recordingState: RecordingState = .idle
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var audioLevels: [CGFloat] = []
    @Published public private(set) var recordedFileURL: URL?
    @Published public private(set) var error: VoiceRecorderError?

    public var isRecording: Bool { recordingState == .recording }
    public var hasRecording: Bool { recordedFileURL != nil }
    public var isPlaying: Bool { recordingState == .playing }

    // MARK: - Private Properties
    private let filePath: URL
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var meteringTimer: Timer?
    private var recordingStartTime: Date?

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

        public var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Microphone permission denied"
            case .recordingFailed:
                return "Could not send recording. Please try again."
            case .playbackFailed:
                return "Could not play recording"
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

    public func stopPlayback() {
        player?.stop()
        player = nil
        stopTimers()
        recordingState = .recorded
        currentTime = 0
    }

    public func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    public func startOver() {
        stopTimers()
        recorder?.stop()
        recorder = nil
        player?.stop()
        player = nil

        if let url = recordedFileURL, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }

        recordedFileURL = nil
        currentTime = 0
        audioLevels = []
        recordingState = .idle
        error = nil
    }

    public func reset() {
        startOver()
    }

    // MARK: - Private Methods
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

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
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

                // Stop when playback finishes
                if !player.isPlaying {
                    self.stopPlayback()
                }
            }
        }

        // Timer for metering audio levels during playback
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePlaybackLevels()
            }
        }
    }

    private func updatePlaybackLevels() {
        guard let player, isPlaying else { return }
        player.updateMeters()
        let power = player.averagePower(forChannel: 0)
        // Normalize: power ranges from -160 to 0
        let normalizedPower = max(0, (power + 50) / 50)
        let level = CGFloat(pow(10, normalizedPower) - 1) / 9  // Scale to 0...1

        audioLevels.append(level)
        // Keep only last 100 samples for visualization
        if audioLevels.count > 100 {
            audioLevels.removeFirst()
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
        // Normalize: power ranges from -160 to 0
        let normalizedPower = max(0, (power + 50) / 50)
        let level = CGFloat(pow(10, normalizedPower) - 1) / 9  // Scale to 0...1

        audioLevels.append(level)
        // Keep only last 100 samples for visualization
        if audioLevels.count > 100 {
            audioLevels.removeFirst()
        }
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
    public var formattedTime: String {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
