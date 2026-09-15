import AVFoundation
import Apollo
import Environment
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

final class SubmitClaimAudioStep: ClaimIntentStepHandler {
    var audioFileURL: URL?
    @Inject var fileUploadClient: hSubmitClaimFileUploadClient
    let audioRecordingModel: ClaimIntentStepContentAudioRecording

    @Published var textInput: String = "" {
        didSet {
            textInputError =
                characterMismatch ? L10n.claimsTextInputMinCharactersError(audioRecordingModel.freeTextMinLength) : nil
        }
    }
    @Published var textInputError: String?
    @Published var isTextInputPresented: Bool = false {
        willSet {
            showTextViewOnAppear = newValue
        }
        didSet {
            updateSkipVisibility()
        }
    }
    @Published var showTextViewOnAppear: Bool = false
    @Published var isAudioInputPresented: Bool = false {
        didSet {
            updateSkipVisibility()
            guard !isAudioInputPresented else { return }
            // Closing mid-countdown: clear the flag the countdown checks before it would start recording.
            voiceRecorder.isCountingDown = false
            voiceRecorder.stopRecording()
            voiceRecorder.stopPlayback()
        }
    }
    @Published var uploadProgress: Double = 0
    private var presentInputTask: Task<Void, Never>?

    let voiceRecorder = VoiceRecorder()
    var characterMismatch: Bool {
        textInput.count < audioRecordingModel.freeTextMinLength
            || textInput.count > audioRecordingModel.freeTextMaxLength
    }

    enum RecordingState {
        case idle
        case recording
        case recorded
        case uploading
    }

    enum AudioRecordingStepType {
        case audio
        case text

        var title: String {
            switch self {
            case .audio:
                return L10n.claimChatAudioRecordingLabel
            case .text:
                return L10n.claimChatFreeTextLabel
            }
        }
    }

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .audioRecording(let model) = claimIntent.currentStep.content else {
            fatalError("AudioRecordingStepHandler initialized with non-audioRecording content")
        }
        self.audioRecordingModel = model
        self.audioFileURL = model.currentAudioUrl
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        if let currentFreeText = model.currentFreeText {
            self.textInput = currentFreeText
            self.isTextInputPresented = true
            self.showTextViewOnAppear = false
        }
    }

    // MARK: - Inline inputs (Skriv / Spela in)

    /// Opens the text card. The question is scrolled to the top first so it stays visible above the card and keyboard.
    func presentTextInput() {
        presentInput { $0.isTextInputPresented = true }
    }

    /// Opens the voice card with a fresh recorder, scrolling the question to the top first like the text card.
    func presentAudioInput() {
        voiceRecorder.startOver()
        presentInput { $0.isAudioInputPresented = true }
    }

    /// Closes whichever card is open and returns to the Skriv / Spela in row.
    func dismissInput() {
        presentInputTask?.cancel()
        UIApplication.dismissKeyboard()
        isTextInputPresented = false
        isAudioInputPresented = false
    }

    /// The docked card is the whole input while it is open: Hoppa över and the frosted panel are only shown
    /// with the Skriv / Spela in row.
    private func updateSkipVisibility() {
        let isCardPresented = isTextInputPresented || isAudioInputPresented
        setDisableSkip(to: isCardPresented)
        state.hidesInputPanelBackground = isCardPresented
    }

    private func presentInput(_ present: @escaping @MainActor (SubmitClaimAudioStep) -> Void) {
        mainHandler(.scrollToStep(id: id))
        presentInputTask?.cancel()
        presentInputTask = Task { @MainActor [weak self] in
            await delay(ClaimChatConstants.Timing.inputCardReveal)
            guard !Task.isCancelled, let self else { return }
            present(self)
        }
    }

    private var uploadedAudioId: String?
    func uploadAudioRecording() async throws {
        // A resumed step carries a remote currentAudioUrl; only local recordings can be uploaded.
        guard let audioFileURL, audioFileURL.isFileURL else {
            throw ClaimIntentError.invalidResponse
        }
        state.isEnabled = false
        do {
            let url = Environment.current.claimsApiURL.appendingPathComponent(audioRecordingModel.uploadURI)
            let multipart = MultipartFormDataRequest(url: url)
            let data = try Data(contentsOf: audioFileURL)
            multipart.addDataField(
                fieldName: "files",
                fileName: audioFileURL.lastPathComponent,
                data: data,
                mimeType: "audio/m4a"
            )
            let response: FileUploadResponseModel = try await fileUploadClient.upload(
                url: audioFileURL,
                multipart: multipart
            ) { [weak self] progress in
                Task { @MainActor in
                    self?.uploadProgress = progress
                }
            }
            uploadedAudioId = response.fileIds.first!
        } catch {
            state.isEnabled = true
            throw error
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        let fileId: String? = {
            if isTextInputPresented {
                return nil
            }
            return uploadedAudioId
        }()
        voiceRecorder.isSending = true
        let freeText = isTextInputPresented ? textInput : nil
        do {
            guard
                let result = try await service.claimIntentSubmitAudio(
                    fileId: fileId,
                    freeText: freeText,
                    stepId: claimIntent.currentStep.id
                )
            else {
                throw ClaimIntentError.invalidResponse
            }
            isAudioInputPresented = false
            Task { [weak voiceRecorder] in
                await delay(ClaimChatConstants.Timing.standardAnimation)
                voiceRecorder?.isSending = false
            }
            return result
        } catch {
            Task { [weak voiceRecorder] in
                await delay(ClaimChatConstants.Timing.standardAnimation)
                voiceRecorder?.isSending = false
            }
            throw error
        }
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedStep
        }
        if isTextInputPresented {
            return .accessibilitySubmittedValue(textInput)
        } else {
            return .accessibilitySubmittedValue(L10n.claimChatAudioRecordingLabel)
        }
    }
}

struct FileUploadResponseModel: Codable, Sendable {
    let fileIds: [String]
}
