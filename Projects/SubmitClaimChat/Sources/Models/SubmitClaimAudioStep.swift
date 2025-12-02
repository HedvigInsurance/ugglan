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
    @Published var textInput: String = ""
    @Published var inputType: AudioRecordingStepType?

    enum RecordingState {
        case idle
        case recording
        case recorded
        case uploading
    }

    enum AudioRecordingStepType {
        case audio
        case text
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

    override func executeStep() async throws -> ClaimIntentType {
        let fileId: String? = try await {
            if inputType == .text {
                return nil
            }
            guard let audioFileURL else {
                throw ClaimIntentError.invalidResponse
            }
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
                    withAnimation {
                        self?.uploadProgress = progress
                    }
                }
            }
            return response.fileIds.first!
        }()

        let freeText = inputType == .text ? textInput : nil

        guard
            let result = try await service.claimIntentSubmitAudio(
                fileId: fileId,
                freeText: freeText,
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }

    deinit {
        if let audioFileURL = audioFileURL {
            try? FileManager.default.removeItem(at: audioFileURL)
        }
    }
}

struct FileUploadResponseModel: Codable, Sendable {
    let fileIds: [String]
}
