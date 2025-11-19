import SwiftUI

final class SubmitClaimTextStep: ClaimIntentStepHandler {
    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        guard case .text = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-text content")
        }
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

        // Acknowledge text step and get next step
        guard let result = try await service.getNextStep(claimIntentId: claimIntent.id) else {
            throw ClaimIntentError.invalidResponse
        }
        mainHandler(result)
        withAnimation {
            isEnabled = false
        }
        return result
    }
}
