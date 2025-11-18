import AVFoundation
import Apollo
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SubmitClaimAudioView: View {
    @EnvironmentObject var viewModel: SubmitClaimAudioStep
    @EnvironmentObject var mainVM: SubmitClaimChatViewModel
    @StateObject var audioPlayer: AudioPlayer
    @StateObject var audioRecorder: AudioRecorder
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @AccessibilityFocusState private var saveAndContinueFocused: Bool

    // UI + alerts
    @State private var showMicAlert = false
    @SwiftUI.Environment(\.openURL) private var openURL

    // Guard while system permission sheet is up; hint after first grant
    @State private var isRequestingMicPermission = false

    @StateObject var audioRecordingVm = AudioRecorderViewModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
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
            ZStack(alignment: .bottom) {
                Group {
                    if let url = audioRecorder.recording?.url {
                        playRecordingButton(url: url)
                    } else if let url = viewModel.audioFileURL {
                        playRecordingButton(url: url)
                    } else {
                        recordNewButton
                    }
                }
            }
            .environmentObject(audioRecorder)
        }
        .sectionContainerStyle(.transparent)
        .alert(
            "Microphone Access Needed",
            isPresented: $showMicAlert,
            actions: {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            },
            message: { Text("Enable microphone access to record audio for your claim.") }
        )
    }

    private func playRecordingButton(url: URL) -> some View {
        VStack(spacing: .padding12) {
            TrackPlayerView(audioPlayer: audioPlayer, withoutBackground: true)
                .onAppear {
                    minutes = 0; seconds = 0
                }

            hButton(
                .large,
                .primary,
                content: .init(title: L10n.saveAndContinueButtonLabel),
                {
                    Task {
                        do {
                            viewModel.audioFileURL = url
                            try await mainVM.submitStep(handler: viewModel)
                            try? FileManager.default.removeItem(at: url)
                        } catch {
                        }
                    }
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear { audioPlayer.url = url }
    }

    private var recordNewButton: some View {
        VStack(spacing: .padding8) {
            RecordButton(isRecording: audioRecorder.isRecording) {
                handleRecordTap()
            }
            .frame(height: audioRecorder.isRecording ? 144 : 72)
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300)))

            if !audioRecorder.isRecording {
                VStack(spacing: .padding4) {
                    hText(L10n.claimsStartRecordingLabel, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityHint(audioRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
    }

    @MainActor
    private func handleRecordTap() {
        if isRequestingMicPermission { return }
        isRequestingMicPermission = true

        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.isRequestingMicPermission = false

                    if granted {
                        do {
                            try self.configureAudioSessionForRecording()
                            withAnimation(.spring()) { self.audioRecorder.toggleRecording() }
                        } catch {
                        }
                    } else {
                        self.showMicAlert = true
                    }
                }
            }
        } else {
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
