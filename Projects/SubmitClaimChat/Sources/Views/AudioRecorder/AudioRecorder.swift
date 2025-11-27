import AVFAudio
import Combine
import SwiftUI
import hCoreUI

@MainActor
public class AudioRecorder: @preconcurrency ObservableObject {
    public static let audioFileExtension = "m4a"
    private let filePath: URL

    public init(filePath: URL) {
        self.filePath = filePath
    }

    public let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    public var isRecording = false { didSet { objectWillChange.send(self) } }
    public var recording: Recording? { didSet { objectWillChange.send(self) } }
    var decibelScale: [CGFloat] = [] { didSet { objectWillChange.send(self) } }

    let recordingTimer = Timer.publish(every: 1 / 30, on: .main, in: .common).autoconnect()
    private var recorder: AVAudioRecorder?

    public func toggleRecording() {
        if isRecording { stopRecording() } else { startRecording() }
    }

    /// Clear current recording and reset the underlying AVAudioRecorder on next start.
    public func restart() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        recording = nil
        decibelScale.removeAll()
    }

    /// Prepare the underlying AVAudioRecorder.
    /// Call ONLY AFTER mic permission is granted and the audio session is configured+active.
    public func prepareIfNeeded() throws {
        if recorder != nil { return }

        // Ensure directory exists
        try FileManager.default.createDirectory(
            at: filePath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // Remove stale file (if any)
        if FileManager.default.fileExists(atPath: filePath.path) {
            try? FileManager.default.removeItem(at: filePath)
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let newRecorder = try AVAudioRecorder(url: filePath, settings: settings)
        newRecorder.isMeteringEnabled = true
        newRecorder.prepareToRecord()
        self.recorder = newRecorder
        self.decibelScale = []
    }

    private func startRecording() {
        do {
            try prepareIfNeeded()
            recorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    func refresh() {
        recorder?.updateMeters()
        let gain = recorder?.averagePower(forChannel: 0) ?? 0
        decibelScale.append(CGFloat(pow(10, gain / 20)))
    }

    private func stopRecording() {
        recorder?.stop()
        isRecording = false

        // Deactivate session first, then optionally drop to a passive category
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
        } catch {
            print("Failed to reset AVAudioSession: \(error)")
        }

        if FileManager.default.fileExists(atPath: filePath.relativePath) {
            recording = Recording(url: filePath, sample: decibelScale)
        }
    }
}

struct AudioPulseBackground: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    @State var scaleEffect: CGFloat = 0
    private let backgroundColorScheme: some hColor = hBorderColor.secondary

    var body: some View {
        Circle().fill(backgroundColorScheme)
            .onReceive(audioRecorder.recordingTimer) { _ in
                audioRecorder.refresh()
            }
            .scaleEffect(scaleEffect)
            .onChange(of: audioRecorder.decibelScale) { _ in
                withAnimation(.spring) {
                    scaleEffect =
                        audioRecorder.isRecording
                        ? pow((audioRecorder.decibelScale.last ?? 0.0) + 0.95, 4)
                        : 0.95
                }
            }
    }
}

public struct Recording {
    public var url: URL
    var sample: [CGFloat]
}

@MainActor
public class AudioRecorderViewModel: ObservableObject {
    @Published public var viewState: ProcessingState = .success
}
