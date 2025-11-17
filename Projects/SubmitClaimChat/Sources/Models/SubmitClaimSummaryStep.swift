import SwiftUI

final class SubmitClaimSummaryStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true

    let summaryModel: ClaimIntentStepContentSummary
    private let service: ClaimIntentService

    required init(claimIntent: ClaimIntent, sender: SubmitClaimChatMesageSender, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.sender = sender
        self.service = service
        guard case .summary(let model) = claimIntent.currentStep.content else {
            fatalError("SummaryStepHandler initialized with non-summary content")
        }
        self.summaryModel = model
    }

    func submitResponse() async throws -> ClaimIntent {
        isLoading = true
        defer { isLoading = false }

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
