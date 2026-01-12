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
            VStack(spacing: .padding12) {
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
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)).animation(.default))
                .animation(.default, value: viewModel.inputType)
                VStack(spacing: .padding4) {
                    buttons
                        .transition(.opacity.animation(.default))
                        .animation(.default, value: viewModel.inputType)
                }
            }
            .environmentObject(audioRecorder)
        }
        .sectionContainerStyle(.transparent)
    }

    private var textElements: some View {
        VStack(spacing: .padding16) {
            textField
        }
    }

    @ViewBuilder
    private var buttons: some View {
        switch viewModel.inputType {
        case .audio:
            if let url = audioRecorder.recording?.url ?? viewModel.audioFileURL {
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
                    {
                        audioRecorder.restart()
                        viewModel.inputType = .none
                    }
                )
            } else {
                if !audioRecorder.isRecording {
                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.claimsUseTextInstead),
                        {
                            viewModel.inputType = .text
                        }
                    )
                }
            }
        case .text:
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.saveAndContinueButtonLabel),
                {
                    UIApplication.dismissKeyboard()
                    viewModel.submitResponse()
                }
            )
            .disabled(viewModel.characterMismatch)
            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.claimsUseAudioRecording),
                {
                    viewModel.inputType = .audio
                }
            )
        case nil:
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.claimChatUseAudio),
                {
                    viewModel.inputType = .audio
                    handleRecordTap()
                }
            )
            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.claimChatUseTextInput),
                {
                    viewModel.inputType = .text
                }
            )
        }
    }

    @ViewBuilder
    private var textField: some View {
        hTextView(
            selectedValue: viewModel.textInput,
            placeholder: L10n.claimsTextInputPlaceholder,
            popupPlaceholder: L10n.claimsTextInputPopoverPlaceholder,
            minCharacters: viewModel.audioRecordingModel.freeTextMinLength,
            maxCharacters: viewModel.audioRecordingModel.freeTextMaxLength,
        ) { text in
            viewModel.textInput = text
        }
        .hTextFieldError(viewModel.textInputError)
    }

    private func playRecordingButton(url: URL) -> some View {
        VStack(spacing: .padding12) {
            TrackPlayerView(audioPlayer: audioPlayer)
                .onAppear {
                    minutes = 0; seconds = 0
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

            if audioRecorder.isRecording {
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

        self.toggleRecording()
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
        VStack {
            if viewModel.inputType == .text {
                HStack {
                    hText(viewModel.textInput)
                        .frame(alignment: .topLeading)
                    Spacer()
                }
                .hPillStyle(color: .grey, colorLevel: .two)
                .hFieldSize(.capsuleShape)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if viewModel.inputType == .audio, let url = viewModel.audioFileURL {
                playRecordingButton(url: url)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    private func playRecordingButton(url: URL) -> some View {
        TrackPlayerView(audioPlayer: AudioPlayer(url: url))
            .trackPlayerBackground {
                Color.clear
                    .hPillStyle(color: .grey, colorLevel: .two)
            }
            .hFieldSize(.extraLarge)
    }
}

extension View {
    func mat(id: String, namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            return matchedTransitionSource(id: id, in: namespace)
        } else {
            return self
        }
    }
}
#Preview {
    let viewModel = SubmitClaimAudioStep(
        claimIntent: .init(
            currentStep: .init(
                content: .audioRecording(
                    model: .init(
                        hint: "",
                        uploadURI: "",
                        freeTextMinLength: 5,
                        freeTextMaxLength: 100
                    )
                ),
                id: "id1",
                text: "Text"
            ),
            id: "id",
            isSkippable: false,
            isRegrettable: false
        ),
        service: .init(),
        mainHandler: { _ in
        }
    )
    viewModel.inputType = .text
    viewModel.textInput = """
        asdasdas
        sadadsasdadsasd
        asddasdas
        asadsasd
        """
    return ScrollView {
        SubmitClaimAudioResultView(
            viewModel: viewModel
        )
    }
}
