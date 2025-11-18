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

    init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void)
    func validateInput() -> Bool
    @discardableResult
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
        service: ClaimIntentService,
        mainHandler: @escaping ((ClaimIntent) -> Void),
    ) -> any ClaimIntentStepHandler {
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
        }
    }
}

// MARK: - Errors
enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
}
