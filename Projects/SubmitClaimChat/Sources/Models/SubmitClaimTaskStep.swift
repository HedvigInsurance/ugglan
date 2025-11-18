import SwiftUI

final class SubmitClaimTaskStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    var claimIntent: ClaimIntent {
        didSet {
            if case let .task(model) = claimIntent.currentStep.content {
                isTaskCompleted = model.isCompleted
            }
        }
    }
    let sender: SubmitClaimChatMesageSender = .hedvig
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var isTaskCompleted: Bool = false

    private let taskModel: ClaimIntentStepContentTask
    private let service: ClaimIntentService

    required init(claimIntent: ClaimIntent, service: ClaimIntentService) {
        self.claimIntent = claimIntent
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
