import Foundation
import hCore
import hCoreUI

@MainActor
class ClaimIntentStepHandler: ObservableObject, @MainActor Identifiable {
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent
    var sender: SubmitClaimChatMesageSender { .member }

    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    let service: ClaimIntentService
    let mainHandler: (ClaimIntent) -> Void

    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
    }

    func validateInput() -> Bool {
        true
    }

    @discardableResult
    func submitResponse() async throws -> ClaimIntent {
        fatalError("submitResponse must be overridden")
    }
}

enum ClaimIntentStepHandlerFactory {
    @MainActor
    static func createHandler(
        for claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping ((ClaimIntent) -> Void)
    ) -> ClaimIntentStepHandler {
        switch claimIntent.currentStep.content {
        case .form:
            return SubmitClaimFormStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .task:
            return SubmitClaimTaskStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .audioRecording:
            return SubmitClaimAudioStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .summary:
            return SubmitClaimSummaryStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .outcome:
            return SubmitClaimOutcomeStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .text:
            return SubmitClaimTextStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .singleSelect:
            return SubmitClaimSingleSelectStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .fileUpload:
            return SubmitClaimFileUploadStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .unknown:
            return SubmitClaimUnknownStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        }
    }
}

// MARK: - Errors
enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
    case unknown
}
