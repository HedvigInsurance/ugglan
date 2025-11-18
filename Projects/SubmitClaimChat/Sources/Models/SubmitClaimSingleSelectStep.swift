import SwiftUI

final class SubmitClaimSingleSelectStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender = .member
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var selectedOption: String?
    let options: [ClaimIntentContentSelectOption]
    private let service: ClaimIntentService

    required init(claimIntent: ClaimIntent, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.service = service
        guard case .singleSelect(let model) = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-single select content")
        }
        self.options = model
    }

    func submitResponse() async throws -> ClaimIntent {
        isLoading = true
        defer { isLoading = false }

        // Acknowledge text step and get next step
        let result = try await service.claimIntentSubmitSelect(
            stepId: claimIntent.currentStep.id,
            selectedValue: selectedOption!
        )
        return result
    }
}

public struct ClaimIntentContentSelectOption: Sendable {
    let id: String
    let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
