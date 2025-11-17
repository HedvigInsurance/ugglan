import AVFoundation
import Apollo
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

final class SubmitClaimAudioStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var recordingState: RecordingState = .idle
    @Published var audioFileURL: URL?
    @Published var audioFileId: String?

    let audioRecordingModel: ClaimIntentStepContentAudioRecording
    private let service: ClaimIntentService

    enum RecordingState {
        case idle
        case recording
        case recorded
        case uploading
    }

    required init(claimIntent: ClaimIntent, sender: SubmitClaimChatMesageSender, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.sender = sender
        self.service = service
        guard case .audioRecording(let model) = claimIntent.currentStep.content else {
            fatalError("AudioRecordingStepHandler initialized with non-audioRecording content")
        }
        self.audioRecordingModel = model
    }

    func startRecording() {
        recordingState = .recording
        // Start recording logic
    }

    func stopRecording() {
        recordingState = .recorded
        // Stop recording logic
    }

    func submitResponse() async throws -> ClaimIntent {
        isLoading = true
        recordingState = .uploading
        defer {
            isLoading = false
            recordingState = .idle
        }

        guard
            let result = try await service.claimIntentSubmitAudio(
                fileId: audioFileId,
                freeText: nil,
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }

        return result
    }
}
