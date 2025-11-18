import SwiftUI

final class SubmitClaimOutcomeStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender = .hedvig
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true

    let outcomeModel: ClaimIntentStepContentOutcome
    private let service: ClaimIntentService
    private let mainHandler: (ClaimIntent) -> Void

    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
        guard case .outcome(let model) = claimIntent.currentStep.content else {
            fatalError("OutcomeStepHandler initialized with non-outcome content")
        }
        self.outcomeModel = model
    }

    func submitResponse() async throws -> ClaimIntent {
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
        mainHandler(result)
        withAnimation {
            isEnabled = false
        }
        return result
    }
}
