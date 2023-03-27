import AVFAudio
import Combine
import SwiftUI
import hCoreUI

class AudioRecorder: ObservableObject {
    private let filename = "claim-recording.m4a"
    private(set) var isRecording = false {
        didSet {
            objectWillChange.send(self)
        }
    }

    private(set) var recording: Recording? {
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
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var recorder: AVAudioRecorder?

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func restart() {
        recording = nil
    }

    private func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.record)
            try recordingSession.setActive(true)
        } catch {
            print("Failed")
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let audioFilename = documentPath.appendingPathComponent(filename)

        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
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
        decibelScale.append(CGFloat(pow(10, (gain / 20))))
    }

    private func stopRecording() {
        recorder?.stop()
        isRecording = false

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard
            let directoryContents = try? fileManager.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )
        else { return }
        self.recording = directoryContents.first(where: { $0.absoluteString.contains(filename) })
            .map { Recording(url: $0, created: Date(), sample: decibelScale) }
    }
}

struct AudioPulseBackground: View {
    @EnvironmentObject var audioRecorder: AudioRecorder

    private let backgroundColorScheme: some hColor = hColorScheme.init(
        light: hGrayscaleColor.one,
        dark: hGrayscaleColor.two
    )

    var body: some View {
        Circle().fill(backgroundColorScheme)
            .onReceive(audioRecorder.recordingTimer) { input in
                audioRecorder.refresh()
            }
            .scaleEffect(audioRecorder.isRecording ? pow(((audioRecorder.decibelScale.last ?? 0.0) + 0.95), 4) : 0.95)
            .animation(.spring())
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
