import SwiftUI

final class SubmitClaimTextStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender = .member
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true

    private let service: ClaimIntentService

    required init(claimIntent: ClaimIntent, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.service = service
        guard case .text = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-text content")
        }
    }

    func submitResponse() async throws -> ClaimIntent {
        isLoading = true
        defer { isLoading = false }

        // Acknowledge text step and get next step
        let result = try await service.getNextStep(claimIntentId: claimIntent.id)
        return result
    }
}
