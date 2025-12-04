import SwiftUI
import hCore

final class SubmitClaimTaskStep: ClaimIntentStepHandler {
    override var id: String { claimIntent.currentStep.id }
    override var sender: SubmitClaimChatMesageSender { .member }
    override var claimIntent: ClaimIntent {
        didSet {
            if case let .task(model) = claimIntent.currentStep.content {
                taskModel = model
            }
        }
    }

    @Published var taskModel: ClaimIntentStepContentTask

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .task(let model) = claimIntent.currentStep.content else {
            fatalError("TaskStepHandler initialized with non-task content")
        }
        self.taskModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        Task {
            try await Task.sleep(seconds: 1)
            await submitResponse()
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        try await getNextStep()
        guard
            let result = try await service.claimIntentSubmitTask(stepId: claimIntent.currentStep.id)
        else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }

    private func getNextStep() async throws {
        if taskModel.isCompleted {
            return
        } else {
            try await Task.sleep(seconds: 0.5)
            guard let claimIntent = try await service.getNextStep(claimIntentId: claimIntent.id) else {
                throw ClaimIntentError.invalidResponse
            }

            switch claimIntent {
            case let .intent(model):
                self.claimIntent = model
            default:
                break
            }

            try await getNextStep()
        }
    }
}
