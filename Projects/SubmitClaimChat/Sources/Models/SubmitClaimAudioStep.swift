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
    @Published var uploadProgress: Double = 0
    @Inject var fileUploadClient: hSubmitClaimFileUploadClient
    let audioRecordingModel: ClaimIntentStepContentAudioRecording
    @Published var textInput: String = "" {
        didSet {
            textInputError =
                characterMismatch ? L10n.claimsTextInputMinCharactersError(audioRecordingModel.freeTextMinLength) : nil
        }
    }
    @Published var textInputError: String?
    @Published var isTextInputPresented: Bool = false
    @Published var isAudioInputPresented: Bool = false
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
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    private var uploadedAudioId: String?
    func uploadAudioRecording() async throws {
        guard let audioFileURL else {
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
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
                voiceRecorder?.isSending = false
            }
            return result
        } catch {
            Task { [weak voiceRecorder] in
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
                voiceRecorder?.isSending = false
            }
            throw error
        }
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedLabel
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
