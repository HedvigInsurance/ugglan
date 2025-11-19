import SwiftUI

final class SubmitClaimTaskStep: ClaimIntentStepHandler {
    override var id: String { claimIntent.currentStep.id }
    override var sender: SubmitClaimChatMesageSender { .hedvig }
    override var claimIntent: ClaimIntent {
        didSet {
            if case let .task(model) = claimIntent.currentStep.content {
                withAnimation {
                    taskModel = model
                }
            }
        }
    }

    @Published var taskModel: ClaimIntentStepContentTask

    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        guard case .task(let model) = claimIntent.currentStep.content else {
            fatalError("TaskStepHandler initialized with non-task content")
        }
        self.taskModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        Task {
            try await Task.sleep(seconds: 1)
            _ = try await submitResponse()
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
        try await getNextStep()
        guard
            let claimIntent = try await service.claimIntentSubmitTask(stepId: claimIntent.currentStep.id)
        else {
            throw ClaimIntentError.invalidResponse
        }
        mainHandler(claimIntent)
        withAnimation {
            isEnabled = false
        }
        return claimIntent
    }

    private func getNextStep() async throws {
        if taskModel.isCompleted {
            return
        } else {
            try await Task.sleep(seconds: 0.5)
            guard let claimIntent = try await service.getNextStep(claimIntentId: claimIntent.id) else {
                throw ClaimIntentError.invalidResponse
            }
            self.claimIntent = claimIntent
            try await getNextStep()
        }
    }
}
