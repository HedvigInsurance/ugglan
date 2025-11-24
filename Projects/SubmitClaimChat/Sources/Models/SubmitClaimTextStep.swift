import SwiftUI

final class SubmitClaimTextStep: ClaimIntentStepHandler {
    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        guard case .text = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-text content")
        }
    }

    override func executeStep() async throws -> ClaimIntent {
        guard let result = try await service.getNextStep(claimIntentId: claimIntent.id) else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }
}
