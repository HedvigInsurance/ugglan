import SwiftUI

final class SubmitClaimTextStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender = .member
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true

    private let service: ClaimIntentService
    private let mainHandler: (ClaimIntent) -> Void

    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
        guard case .text = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-text content")
        }
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

        // Acknowledge text step and get next step
        let result = try await service.getNextStep(claimIntentId: claimIntent.id)
        mainHandler(result)
        withAnimation {
            isEnabled = false
        }
        return result
    }
}
