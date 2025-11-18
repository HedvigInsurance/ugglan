import Foundation
import hCore
import hCoreUI

@MainActor
protocol ClaimIntentStepHandler: AnyObject, ObservableObject, Identifiable {
    var id: String { get }
    var claimIntent: ClaimIntent { get }
    var sender: SubmitClaimChatMesageSender { get }
    var isLoading: Bool { get set }
    var isEnabled: Bool { get set }

    init(claimIntent: ClaimIntent, service: ClaimIntentService)
    func validateInput() -> Bool
    func submitResponse() async throws -> ClaimIntent
}

extension ClaimIntentStepHandler {
    func validateInput() -> Bool {
        true
    }
}

enum ClaimIntentStepHandlerFactory {
    @MainActor
    static func createHandler(
        for claimIntent: ClaimIntent,
        service: ClaimIntentService
    ) -> any ClaimIntentStepHandler {
        switch claimIntent.currentStep.content {
        case .form:
            return SubmitClaimFormStep(claimIntent: claimIntent, service: service)
        case .task:
            return SubmitClaimTaskStep(claimIntent: claimIntent, service: service)
        case .audioRecording:
            return SubmitClaimAudioStep(claimIntent: claimIntent, service: service)
        case .summary:
            return SubmitClaimSummaryStep(claimIntent: claimIntent, service: service)
        case .outcome:
            return OutcomeStepHandler(claimIntent: claimIntent, service: service)
        case .text:
            return SubmitClaimTextStep(claimIntent: claimIntent, service: service)
        case .singleSelect:
            return SubmitClaimSingleSelectStep(claimIntent: claimIntent, service: service)
        }
    }
}

// MARK: - Errors
enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
}
