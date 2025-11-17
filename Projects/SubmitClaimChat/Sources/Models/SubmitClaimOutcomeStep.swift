import SwiftUI

final class OutcomeStepHandler: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true

    let outcomeModel: ClaimIntentStepContentOutcome
    private let service: ClaimIntentService

    required init(claimIntent: ClaimIntent, sender: SubmitClaimChatMesageSender, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.sender = sender
        self.service = service
        guard case .outcome(let model) = claimIntent.currentStep.content else {
            fatalError("OutcomeStepHandler initialized with non-outcome content")
        }
        self.outcomeModel = model
    }

    func submitResponse() async throws -> ClaimIntent {
        isLoading = true
        defer { isLoading = false }

        // Outcome is typically the final step, get next step to check for any continuation
        let result = try await service.getNextStep(claimIntentId: claimIntent.id)
        return result
    }
}
