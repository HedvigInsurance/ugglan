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

    public var isRecording = false {
        didSet {
            objectWillChange.send(self)
        }
    }

    public var recording: Recording? {
        didSet {
            objectWillChange.send(self)
        }
    }

    var decibelScale: [CGFloat] = [] {
        didSet {
            objectWillChange.send(self)
        }
    }

    let recordingTimer = Timer.publish(every: 1 / 30, on: .main, in: .common)
        .autoconnect()

    public let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var recorder: AVAudioRecorder?

    public func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    public func restart() {
        recording = nil
    }

    private func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.record)
            try recordingSession.setActive(true)
            try FileManager.default.removeItem(at: filePath)
        } catch {
            print("Failed")
        }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            recorder = try AVAudioRecorder(url: filePath, settings: settings)
            decibelScale = []
            recorder?.record()
            recorder?.isMeteringEnabled = true
            isRecording = true
        } catch {
            print("Could not start recording")
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

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to reset AVAudioSession: \(error)")
        }

        if FileManager.default.fileExists(atPath: filePath.relativePath) {
            recording = Recording(url: filePath, created: Date(), sample: decibelScale)
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
            .scaleEffect(
                scaleEffect
            )
            .onChange(of: audioRecorder.decibelScale) { _ in
                withAnimation(.spring) {
                    scaleEffect =
                        audioRecorder.isRecording ? pow((audioRecorder.decibelScale.last ?? 0.0) + 0.95, 4) : 0.95
                }
            }
    }
}

public struct Recording {
    public var url: URL
    var created: Date
    var sample: [CGFloat]
    var max: CGFloat {
        sample.max() ?? 1.0
    }

    var range: Range<CGFloat> {
        guard sample.count > 0 else { return 0..<0 }
        return sample.min()!..<sample.max()!
    }
}
