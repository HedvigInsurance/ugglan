import AVFAudio
import Speech
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatInputView: View {
    @ObservedObject var viewModel: SubmitClaimChatInputViewModel
    @State var height: CGFloat = 0
    let placeHolder: String

    var body: some View {
        HStack {
            CustomTextViewRepresentable(
                placeholder: placeHolder,
                text: $viewModel.inputText,
                height: $height,
                keyboardIsShown: $viewModel.keyboardIsShown,
                onSend: { viewModel.sendTextMessage() }
            )
            .frame(height: height)
            .frame(minHeight: 40)

            Spacer()
            hCoreUIAssets.mic.view
                .foregroundColor(recordingColor)
                .onTapGesture { viewModel.isRecording.toggle() }
        }
        .padding(.horizontal, .padding16)
        .padding(.vertical, .padding8)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(hSurfaceColor.Opaque.secondary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
        .padding(.horizontal, .padding16)
        .onChange(of: viewModel.isRecording) { rec in
            if rec { viewModel.startRecording() } else { viewModel.stopRecording() }
        }
        .onDisappear { viewModel.stopRecording() }
    }

    @hColorBuilder
    var recordingColor: some hColor {
        if viewModel.isRecording { hSignalColor.Red.element } else { hTextColor.Opaque.primary }
    }
}

// MARK: - ViewModel
@MainActor
class SubmitClaimChatInputViewModel: NSObject, ObservableObject {
    @Published var inputText: String = ""
    @Published var isRecording: Bool = false
    @Published var keyboardIsShown = false

    private var recorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private(set) var currentRecordingURL: URL?
    private var pendingURLForTranscription: URL?
    private var startToken = UUID()
    private lazy var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var urlRecognitionTask: SFSpeechRecognitionTask?

    /// Triggers when a recording has finished (URL reference only).
    @Published var lastAudioReference: String?

    /// Triggers when speech recognition produced a final transcription for the last finished recording.
    @Published var lastFinalTranscription: String?

    func startRecording() {
        let token = UUID()
        startToken = token

        Task { [weak self] in
            guard let self else { return }
            let ok = await requestMicPermission()
            guard ok, self.isStillCurrentStart(token) else { return }
            do {
                try await self._configureAndStartRecorderIfCurrent(token)
            } catch {
                self.failStopIfCurrent(token)
            }
        }
    }

    func stopRecording() {
        startToken = UUID()

        levelTimer?.invalidate(); levelTimer = nil

        let url = currentRecordingURL
        pendingURLForTranscription = url

        recorder?.stop()
        recorder = nil

        isRecording = false

        try? AVAudioSession.sharedInstance()
            .setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: Helpers
    private func isStillCurrentStart(_ token: UUID) -> Bool {
        startToken == token && isRecording
    }

    private func failStopIfCurrent(_ token: UUID) {
        if isStillCurrentStart(token) { stopRecording() }
    }

    private func makeRecordingURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("voice-\(UUID().uuidString).m4a")
    }

    private func handleRecordedAudio(_ url: URL) {
        print("Recorded voice note at:", url)
    }

    // MARK: Permissions
    private func requestMicPermission() async -> Bool {
        let session = AVAudioSession.sharedInstance()
        var granted = false
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            session.requestRecordPermission { g in
                granted = g; c.resume()
            }
        }
        return granted
    }

    private func ensureSpeechPermission() async -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .notDetermined {
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                SFSpeechRecognizer.requestAuthorization { _ in cont.resume() }
            }
        }
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    // MARK: Start AVAudioRecorder
    private func _configureAndStartRecorderIfCurrent(_ token: UUID) async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        guard isStillCurrentStart(token) else {
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            return
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let url = makeRecordingURL()
        currentRecordingURL = url
        // Do NOT set lastAudioReference here — it would fire too early.

        let rec = try AVAudioRecorder(url: url, settings: settings)
        rec.isMeteringEnabled = true
        rec.delegate = self
        rec.prepareToRecord()

        guard isStillCurrentStart(token) else {
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            return
        }

        rec.record()
        recorder = rec
        startLevelTimer()
    }

    private func startLevelTimer() {
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateLevel),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(levelTimer!, forMode: .common)
    }

    @objc private func updateLevel() {
        guard let rec = recorder else { return }
        rec.updateMeters()
        _ = rec.averagePower(forChannel: 0)
        // Publish a meter value if you want a waveform
    }

    // MARK: Transcription

    private func transcribeRecording(at url: URL) {
        Task {
            guard await ensureSpeechPermission() else {
                await MainActor.run {
                    if self.inputText.isEmpty { self.inputText = "[Taligenkänning nekades]" }
                }
                return
            }
            guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                await MainActor.run {
                    if self.inputText.isEmpty { self.inputText = "[Taligenkänning ej tillgänglig]" }
                }
                return
            }

            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = true
            request.taskHint = .dictation
            request.requiresOnDeviceRecognition = false

            await MainActor.run {
                // Clear any leftover status; keep placeholder if still empty
                self.urlRecognitionTask?.cancel()
                self.urlRecognitionTask = nil
            }

            let task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                Task { @MainActor in
                    if let r = result {
                        self.inputText = r.bestTranscription.formattedString
                        if r.isFinal {
                            // Publish the final transcript so the screen can show it
                            self.lastFinalTranscription = self.inputText
                            self.urlRecognitionTask = nil
                        }
                    }
                    if let err = error as NSError? {
                        print("Speech error:", err)
                        if self.inputText.isEmpty {
                            self.inputText = "[Kunde inte transkribera ljudet]"
                        }
                        self.urlRecognitionTask = nil
                    }
                }
            }
            await MainActor.run { self.urlRecognitionTask = task }
        }
    }
}

@MainActor
extension SubmitClaimChatInputViewModel: @preconcurrency AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag, let url = pendingURLForTranscription else {
            print("Recording not successful or no URL")
            pendingURLForTranscription = nil
            return
        }
        pendingURLForTranscription = nil
        handleRecordedAudio(url)
        transcribeRecording(at: url)

        // Publish ONLY after a successful finish (triggers .onChange in the screen)
        lastAudioReference = url.lastPathComponent
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Recorder encode error:", error ?? "")
    }

    func sendTextMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
    }
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var keyboardIsShown: Bool
    @Environment(\.colorScheme) var schema
    var onSend: (() -> Void)? = nil

    func makeUIView(context _: Context) -> some UIView {
        CustomTextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            keyboardIsShown: $keyboardIsShown,
            onSend: onSend
        )
    }

    func updateUIView(_ uiView: UIViewType, context _: Context) {
        guard let tv = uiView as? CustomTextView else { return }

        // Keep placeholder in sync with SwiftUI value
        tv.setPlaceholder(placeholder)

        if tv.text != text {
            tv.text = text
            if tv.isFirstResponder == false {
                let end = (tv.text as NSString).length
                tv.selectedRange = NSRange(location: end, length: 0)
            }
            tv.updateHeight()
        }
        tv.updateColors()  // placeholder visibility driven by emptiness
    }
}

// MARK: - UITextView subclass

@MainActor
private class CustomTextView: UITextView, UITextViewDelegate {
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var keyboardIsShown: Bool
    private var placeholderLabel = UILabel()
    private var onSend: (() -> Void)?

    init(
        placeholder: String,
        inputText: Binding<String>,
        height: Binding<CGFloat>,
        keyboardIsShown: Binding<Bool>,
        onSend: (() -> Void)? = nil
    ) {
        _inputText = inputText
        _height = height
        _keyboardIsShown = keyboardIsShown
        self.onSend = onSend
        super.init(frame: .zero, textContainer: nil)
        textContainerInset = .init(top: 4, left: 4, bottom: 4, right: 4)
        delegate = self
        isScrollEnabled = false
        font = Fonts.fontFor(style: .body1)
        text = inputText.wrappedValue
        textColor = UIColor.black
        backgroundColor = .clear

        placeholderLabel.font = Fonts.fontFor(style: .body1)
        placeholderLabel.text = placeholder
        addSubview(placeholderLabel)
        placeholderLabel.accessibilityElementsHidden = true
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(8)
        }
        accessibilityLabel = placeholderLabel.text

        updateColors()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setPlaceholder(_ text: String) {
        if placeholderLabel.text != text {
            placeholderLabel.text = text
            accessibilityLabel = text
        }
        // visibility still driven by emptiness of the actual text
    }

    func textViewDidBeginEditing(_: UITextView) { keyboardIsShown = true }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            onSend?()
            return false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.inputText = textView.text
            self?.updateHeight()
            self?.updateColors()
        }
        return true
    }

    func textViewDidEndEditing(_: UITextView) { keyboardIsShown = false }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.height = min(self.contentSize.height, 150)
            }
        }
    }

    func updateColors() {
        placeholderLabel.isHidden = !(self.text?.isEmpty ?? true)
        placeholderLabel.textColor = placeholderTextColor
        textColor = editingTextColor
    }

    private var editingTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.Opaque.primary.colorFor(colorScheme, .base).color.uiColor()
    }

    private var placeholderTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.Opaque.secondary.colorFor(colorScheme, .base).color.uiColor()
    }
}
