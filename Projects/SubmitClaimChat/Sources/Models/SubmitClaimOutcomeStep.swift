import SwiftUI

final class SubmitClaimOutcomeStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMesageSender { .hedvig }

    let outcomeModel: ClaimIntentStepContentOutcome

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .outcome(let model) = claimIntent.currentStep.content else {
            fatalError("OutcomeStepHandler initialized with non-outcome content")
        }
        self.outcomeModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntent {
        guard
            let result = try await service.getNextStep(claimIntentId: claimIntent.id)

        else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }
}
