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
    init(claimIntent: ClaimIntent, sender: SubmitClaimChatMesageSender, service: ClaimIntentService)
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
        sender: SubmitClaimChatMesageSender,
        service: ClaimIntentService
    ) -> any ClaimIntentStepHandler {
        switch claimIntent.currentStep.content {
        case .form:
            return SubmitClaimFormStep(claimIntent: claimIntent, sender: sender, service: service)
        case .task:
            return SubmitClaimTaskStep(claimIntent: claimIntent, sender: sender, service: service)
        case .audioRecording:
            return SubmitClaimAudioStep(claimIntent: claimIntent, sender: sender, service: service)
        case .summary:
            return SubmitClaimSummaryStep(claimIntent: claimIntent, sender: sender, service: service)
        case .outcome:
            return OutcomeStepHandler(claimIntent: claimIntent, sender: sender, service: service)
        case .text:
            return SubmitClaimTextStep(claimIntent: claimIntent, sender: sender, service: service)
        case .singleSelect:
            return SubmitClaimSingleSelectStep(claimIntent: claimIntent, sender: sender, service: service)
        }
    }
}

// MARK: - Errors
enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
}
