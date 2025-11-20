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

    override func submitResponse() async throws {
        withAnimation {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }

        // Acknowledge text step and get next step
        guard let result = try await service.getNextStep(claimIntentId: claimIntent.id) else {
            throw ClaimIntentError.invalidResponse
        }

        switch result {
        case let .intent(model):
            mainHandler(.goToNext(claimIntent: model))
        case let .outcome(model):
            mainHandler(.outcome(model: model))
        }

        withAnimation {
            isEnabled = false
        }
    }
}
