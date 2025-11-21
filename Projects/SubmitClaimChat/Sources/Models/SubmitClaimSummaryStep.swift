import SwiftUI
import hCoreUI

final class SubmitClaimSummaryStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMesageSender { .hedvig }

    let summaryModel: ClaimIntentStepContentSummary

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .summary(let model) = claimIntent.currentStep.content else {
            fatalError("SummaryStepHandler initialized with non-summary content")
        }
        self.summaryModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntent {
        guard
            let result = try await service.claimIntentSubmitSummary(
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }
}
