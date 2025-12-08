import AVFoundation
import Apollo
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SubmitClaimAudioView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @StateObject var audioPlayer: AudioPlayer
    @StateObject var audioRecorder: AudioRecorder
    @StateObject var audioRecordingVm = AudioRecorderViewModel()

    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @AccessibilityFocusState private var saveAndContinueFocused: Bool

    @State private var showMicAlert = false
    @Environment(\.openURL) private var openURL
    @State private var isRequestingMicPermission = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(viewModel: SubmitClaimAudioStep) {
        self.viewModel = viewModel
        self._audioPlayer = StateObject(wrappedValue: AudioPlayer(url: nil))
        let tmpDir = FileManager.default.temporaryDirectory
        let path =
            tmpDir
            .appendingPathComponent("claims", isDirectory: true)
            .appendingPathComponent("audio-file-recording")
            .appendingPathExtension(AudioRecorder.audioFileExtension)
        try? ensureParentDirectory(for: path)
        self._audioRecorder = StateObject(wrappedValue: AudioRecorder(filePath: path))
    }

    public var body: some View {
        hSection {
            Group {
                if let inputType = viewModel.inputType {
                    switch inputType {
                    case .audio:
                        if let url = audioRecorder.recording?.url {
                            playRecordingButton(url: url)
                        } else if let url = viewModel.audioFileURL {
                            playRecordingButton(url: url)
                        } else {
                            recordNewButton
                        }
                    case .text:
                        textElements
                    }
                } else {
                    selectInputType
                }
            }
            .environmentObject(audioRecorder)
        }
        .sectionContainerStyle(.transparent)
    }

    private var selectInputType: some View {
        VStack(spacing: .padding4) {
            hButton(
                .large,
                .primary,
                content: .init(title: "Record voice note"),
                {
                    withAnimation {
                        viewModel.inputType = .audio
                    }
                }
            )
            hButton(
                .large,
                .ghost,
                content: .init(title: "Describe with text"),
                {
                    withAnimation {
                        viewModel.inputType = .text
                    }
                }
            )
        }
    }

    private var textElements: some View {
        VStack(spacing: .padding16) {
            textField
            VStack(spacing: .padding4) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.saveAndContinueButtonLabel),
                    {
                        UIApplication.dismissKeyboard()
                        viewModel.submitResponse()
                    }
                )
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.claimsUseAudioRecording),
                    {
                        withAnimation {
                            viewModel.inputType = .audio
                        }
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var textField: some View {
        hTextView(
            selectedValue: viewModel.textInput,
            placeholder: L10n.claimsTextInputPlaceholder,
            popupPlaceholder: L10n.claimsTextInputPopoverPlaceholder,
            maxCharacters: 2000,
            enableTransition: false
        ) { text in
            viewModel.textInput = text
        }
    }

    private func playRecordingButton(url: URL) -> some View {
        VStack(spacing: .padding12) {
            TrackPlayerView(audioPlayer: audioPlayer)
                .onAppear {
                    minutes = 0; seconds = 0
                }
            VStack(spacing: .padding4) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.saveAndContinueButtonLabel),
                    {
                        viewModel.audioFileURL = url
                        viewModel.submitResponse()
                    }
                )
                .disabled(audioRecordingVm.viewState == .loading)
                .hButtonIsLoading(audioRecordingVm.viewState == .loading)
                .accessibilityFocused($saveAndContinueFocused)
                .accessibilityLabel(Text(L10n.saveAndContinueButtonLabel))

                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.embarkRecordAgain),
                    { withAnimation(.spring()) { audioRecorder.restart() } }
                )
            }
        }
        .onAppear { audioPlayer.url = url }
    }

    private var recordNewButton: some View {
        VStack(spacing: .padding8) {
            RecordButton(isRecording: audioRecorder.isRecording) {
                handleRecordTap()
            }
            .frame(height: audioRecorder.isRecording ? 144 : 72)

            if !audioRecorder.isRecording {
                VStack(spacing: .padding4) {
                    hText(L10n.claimsStartRecordingLabel, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.claimsUseTextInstead),
                        {
                            withAnimation {
                                viewModel.inputType = .text
                            }
                        }
                    )
                }
            } else {
                hText(String(format: "%02d:%02d", minutes, seconds), style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .onReceive(timer) { _ in
                        if (seconds % 59) == 0, seconds != 0 { minutes += 1; seconds = 0 } else { seconds += 1 }
                    }
            }
        }
        .onChange(of: audioRecorder.isRecording) { isRecording in
            if !isRecording {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIAccessibility.post(notification: .announcement, argument: " ")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        saveAndContinueFocused = true
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityHint(audioRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
    }

    @MainActor
    private func handleRecordTap() {
        if isRequestingMicPermission { return }
        isRequestingMicPermission = true

        Task {
            let result = await audioRecorder.requestAndToggleRecording()
            self.isRequestingMicPermission = false

            switch result {
            case .permissionDenied:
                self.showMicAlert = true
            case .success:
                break
            case .error:
                break
            }
        }
    }

    private func configureAudioSessionForRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [.defaultToSpeaker, .allowBluetoothHFP]
        )
        try session.setActive(true, options: [])
    }
}

// MARK: - URL helpers
private func ensureParentDirectory(for fileURL: URL) throws {
    let dir = fileURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
}

enum RecordingResult {
    case success
    case permissionDenied
    case error
}

extension AudioRecorder {
    @MainActor
    func requestAndToggleRecording() async -> RecordingResult {
        let granted = await withCheckedContinuation { continuation in
            let handler: @Sendable (Bool) -> Void = { granted in
                DispatchQueue.main.async {
                    continuation.resume(returning: granted)
                }
            }
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission(completionHandler: handler)
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission(handler)
            }
        }

        guard granted else {
            return .permissionDenied
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .spokenAudio,
                options: [.defaultToSpeaker, .allowBluetoothHFP]
            )
            try session.setActive(true, options: [])
        } catch {
            print("Error configuring audio session: \(error)")
            return .error
        }

        withAnimation(.spring()) { self.toggleRecording() }
        return .success
    }
}

struct SubmitClaimAudioResultView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @StateObject var audioPlayer: AudioPlayer = AudioPlayer(url: nil)

    init(viewModel: SubmitClaimAudioStep) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.inputType == .text {
            hTextView(
                selectedValue: viewModel.textInput,
                placeholder: L10n.claimsTextInputPlaceholder,
                popupPlaceholder: L10n.claimsTextInputPopoverPlaceholder,
                maxCharacters: 2000,
                enableTransition: false,
                enabled: false,
                color: UIColor(dynamic: { trait in
                    let style = trait.userInterfaceStyle
                    return hSurfaceColor.Translucent.primary.colorFor(style == .dark ? .dark : .light, .base).color
                        .uiColor()
                })
            )
        } else if viewModel.inputType == .audio, let url = viewModel.audioFileURL {
            playRecordingButton(url: url)
        }
    }

    private func playRecordingButton(url: URL) -> some View {
        TrackPlayerView(audioPlayer: AudioPlayer(url: audioPlayer.url))
            .trackPlayerBackground {
                Color.clear
                    .hPillStyle(color: .grey)
            }
    }
}
