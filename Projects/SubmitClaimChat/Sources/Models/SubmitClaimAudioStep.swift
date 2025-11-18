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

    enum RecordingState {
        case idle
        case recording
        case recorded
        case uploading
    }

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (ClaimIntent, Bool) -> Void
    ) {
        guard case .audioRecording(let model) = claimIntent.currentStep.content else {
            fatalError("AudioRecordingStepHandler initialized with non-audioRecording content")
        }
        self.audioRecordingModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    @discardableResult
    override func submitResponse() async throws -> ClaimIntent {
        guard let audioFileURL else {
            throw ClaimIntentError.invalidResponse
        }
        withAnimation {
            isLoading = true
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
        )
        let fileId = response.fileIds.first!
        defer {
            withAnimation {
                isLoading = false
            }
        }

        guard
            let result = try await service.claimIntentSubmitAudio(
                fileId: fileId,
                freeText: nil,
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }

        mainHandler(result, false)
        withAnimation {
            isEnabled = false
        }
        return result
    }

    struct FileUploadResponseModel: Codable, Sendable {
        let fileIds: [String]
    }
}
