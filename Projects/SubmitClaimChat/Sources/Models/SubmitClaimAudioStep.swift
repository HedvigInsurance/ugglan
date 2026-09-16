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
        didSet { updateTextInputError() }
    }
    @Published private(set) var textInputError: String?
    /// Which input is showing in the docked area. `.text` / `.voice` replace the whole area with a card.
    @Published private(set) var inputMode: InputMode = .choose {
        didSet {
            guard inputMode != .voice, oldValue == .voice else { return }
            // Closing mid-countdown: clear the flag the countdown checks before it would start recording.
            voiceRecorder.isCountingDown = false
            voiceRecorder.stopRecording()
            voiceRecorder.stopPlayback()
        }
    }
    /// The text card focuses its field when the member tapped Skriv, but not when a resumed step opens pre-filled.
    @Published private(set) var shouldFocusTextInput = false
    /// How the step was answered; drives the result bubble and the request payload.
    @Published private(set) var submittedKind: AudioRecordingStepType?
    @Published var uploadProgress: Double = 0

    let voiceRecorder = VoiceRecorder()
    var characterMismatch: Bool {
        textInput.count < audioRecordingModel.freeTextMinLength
            || textInput.count > audioRecordingModel.freeTextMaxLength
    }

    override var usesFloatingInputCard: Bool { inputMode != .choose }

    enum InputMode {
        case choose
        case text
        case voice
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
            self.inputMode = .text
            self.submittedKind = .text
            updateTextInputError()
        } else if model.currentAudioUrl != nil {
            self.submittedKind = .audio
        }
    }

    // MARK: - Inline inputs (Skriv / Spela in)

    /// Opens the text card and focuses its field. The card scrolls the question into view itself.
    func beginText() {
        shouldFocusTextInput = true
        inputMode = .text
    }

    /// Opens the voice card with a fresh recorder.
    func beginVoice() {
        voiceRecorder.startOver()
        inputMode = .voice
    }

    /// Closes whichever card is open and returns to the Skriv / Spela in row.
    func cancelInput() {
        UIApplication.dismissKeyboard()
        shouldFocusTextInput = false
        inputMode = .choose
    }

    /// Submits the text card.
    func saveText() {
        submitResponse()
    }

    /// Uploads the recording and submits the voice card.
    func saveVoice() async throws {
        audioFileURL = voiceRecorder.recordedFileURL
        try await uploadAudioRecording()
        submitResponse()
    }

    /// Only complain once there is something to complain about - an empty card should not show an error.
    private func updateTextInputError() {
        textInputError =
            !textInput.isEmpty && characterMismatch
            ? L10n.claimsTextInputMinCharactersError(audioRecordingModel.freeTextMinLength) : nil
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
        let isText = inputMode == .text
        submittedKind = isText ? .text : .audio
        let fileId: String? = isText ? nil : uploadedAudioId
        voiceRecorder.isSending = true
        let freeText = isText ? textInput : nil
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
            voiceRecorder.stopPlayback()
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
        if submittedKind == .text {
            return .accessibilitySubmittedValue(textInput)
        } else {
            return .accessibilitySubmittedValue(L10n.claimChatAudioRecordingLabel)
        }
    }
}

struct FileUploadResponseModel: Codable, Sendable {
    let fileIds: [String]
}
