import AVFAudio
import Combine
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct EmbarkRecorderTracking {
    var onPlay: hAnalyticsParcel
    var onRetry: hAnalyticsParcel
    var onSubmit: hAnalyticsParcel
    var onStop: hAnalyticsParcel
    var onStart: hAnalyticsParcel

    init(
        storyName: String,
        store: [String: String?]
    ) {
        self.onPlay = hAnalyticsEvent.embarkAudioRecordingPlayback(
            storyName: storyName,
            store: store
        )
        self.onRetry = hAnalyticsEvent.embarkAudioRecordingRetry(
            storyName: storyName,
            store: store
        )
        self.onSubmit = hAnalyticsEvent.embarkAudioRecordingSubmitted(
            storyName: storyName,
            store: store
        )
        self.onStop = hAnalyticsEvent.embarkAudioRecordingStopped(
            storyName: storyName,
            store: store
        )
        self.onStart = hAnalyticsEvent.embarkAudioRecordingBegin(
            storyName: storyName,
            store: store
        )
    }
}

public struct SubmitClaimAudioRecordingScreen: View {
    @PresentableStore var store: ClaimsStore
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder

    let onSubmit: (_ url: URL) -> Void
    var tracking: EmbarkRecorderTracking

    /* TODO: CHANGE THIS */
    public init() {

        let url = URL(string: "https://www.bing.com/az/hprichbg/rb/AdobeSantaFe_EN-US4037753534_1920x1080.jpg")
        audioPlayer = AudioPlayer(url: url!)

        audioRecorder = AudioRecorder()
        tracking = EmbarkRecorderTracking(storyName: "test", store: ["": ""])

        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {

        hForm {

            HStack(spacing: 0) {
                hText(L10n.Message.Claims.Record.short)
                    .foregroundColor(hLabelColor.primary)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .padding(.top, 20)
            .hShadow()

            HStack(spacing: 0) {
                hText(L10n.Message.Claims.Record.message1)
                    .foregroundColor(hLabelColor.primary)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .hShadow()

            HStack(spacing: 0) {
                hText(L10n.Message.Claims.Record.message4)
                    .foregroundColor(hLabelColor.primary)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .hShadow()

            HStack(spacing: 0) {
                hText(L10n.Message.Claims.Record.message3)
                    .foregroundColor(hLabelColor.primary)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .hShadow()

        }
        .hFormAttachToBottom {

            ZStack(alignment: .bottom) {

                if let recording = audioRecorder.recording {
                    VStack(spacing: 12) {

                        /* TODO: Change the audioplayer to take audioplayer as an input */
                        TrackPlayer(audioPlayer: audioPlayer)  // {
                        //                            tracking.onPlay.send()

                        hButton.LargeButtonFilled {
                            guard let url = audioRecorder.recording?.url else {
                                return
                            }
                            tracking.onSubmit.send()
                            onSubmit(url)
                            store.send(.openSuccessScreen)
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        hButton.LargeButtonText {
                            tracking.onRetry.send()
                            withAnimation(.spring()) {
                                audioRecorder.restart()
                            }
                        } content: {
                            hText(L10n.embarkRecordAgain)
                        }
                    }
                    //                    }
                    .transition(.move(edge: .bottom))
                } else {

                    RecordButton(isRecording: audioRecorder.isRecording) {
                        if audioRecorder.isRecording {
                            tracking.onStop.send()
                        } else {
                            tracking.onStart.send()
                        }

                        withAnimation(.spring()) {
                            audioRecorder.toggleRecording()
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300)))
                    .padding(.top, UIScreen.main.bounds.size.height / 1.7)
                }
            }
            .environmentObject(audioRecorder)
        }
    }
}

struct SubmitClaimAudioRecordingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimAudioRecordingScreen()
    }
}

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

struct RecordButton: View {
    var isRecording: Bool
    var onTap: () -> Void

    @ViewBuilder var pulseBackground: some View {
        if isRecording {
            AudioPulseBackground()
        } else {
            Color.clear
        }
    }

    var body: some View {
        ZStack {
            pulseBackground
            SwiftUI.Button {
                onTap()
            } label: {

            }
            .buttonStyle(RecordButtonStyle(isRecording: isRecording))
        }
    }
}

struct RecordButtonStyle: SwiftUI.ButtonStyle {
    var isRecording: Bool

    @hColorBuilder var innerCircleColor: some hColor {
        if isRecording {
            hLabelColor.primary
        } else {
            hTintColor.red
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle().fill(innerCircleColor).frame(width: 36, height: 36)
                .cornerRadius(isRecording ? 1 : 18)
                .padding(36)
        }
        .background(Circle().fill(hBackgroundColor.secondary))
        .shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 4)
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
