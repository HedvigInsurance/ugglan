import SwiftUI

final class SubmitClaimOutcomeStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMesageSender { .hedvig }

    let outcomeModel: ClaimIntentStepContentOutcome

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (ClaimIntent, Bool) -> Void
    ) {
        guard case .outcome(let model) = claimIntent.currentStep.content else {
            fatalError("OutcomeStepHandler initialized with non-outcome content")
        }
        self.outcomeModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func submitResponse() async throws -> ClaimIntent {
        withAnimation {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }

        // Outcome is typically the final step, get next step to check for any continuation
        let result = try await service.getNextStep(claimIntentId: claimIntent.id)
        mainHandler(result, false)
        withAnimation {
            isEnabled = false
        }
        return result
    }
}
