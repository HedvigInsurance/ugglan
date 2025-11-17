import SwiftUI

final class SubmitClaimTaskStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var isTaskCompleted: Bool = false

    private let taskModel: ClaimIntentStepContentTask
    private let service: ClaimIntentService

    required init(claimIntent: ClaimIntent, sender: SubmitClaimChatMesageSender, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.sender = sender
        self.service = service
        guard case .task(let model) = claimIntent.currentStep.content else {
            fatalError("TaskStepHandler initialized with non-task content")
        }
        self.taskModel = model
        self.isTaskCompleted = model.isCompleted
    }

    func submitResponse() async throws -> ClaimIntent {
        isLoading = true
        defer { isLoading = false }

        guard
            let result = try await service.claimIntentSubmitTask(
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }

        return result
    }

    func toggleTaskCompletion() {
        isTaskCompleted.toggle()
    }
}
