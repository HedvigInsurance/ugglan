import SwiftUI
import hCore

final class SubmitClaimTaskStep: ClaimIntentStepHandler {
    override var id: String { claimIntent.currentStep.id }
    override var sender: SubmitClaimChatMessageSender { .hedvig }
    override var claimIntent: ClaimIntent {
        didSet {
            if case let .task(model) = claimIntent.currentStep.content {
                taskModel = model
            }
        }
    }

    @Published var taskModel: ClaimIntentStepContentTask
    @Published var displayText: String?

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
        state.showResults = true
        displayText = taskModel.description
        Task { [weak self] in
            try await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
            self?.submitResponse()
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        state.showResults = true
        do {
            try await getNextStep()
            guard
                let result = try await service.claimIntentSubmitTask(stepId: claimIntent.currentStep.id)
            else {
                throw ClaimIntentError.invalidResponse
            }
            try await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
            Task {
                await delay(1)
                displayText = nil
            }
            taskModel = .init(description: "", isCompleted: true)
            return result
        } catch {
            state.isLoaderAnimating = false
            throw error
        }
    }

    private func getNextStep() async throws {
        if taskModel.isCompleted {
            return
        } else {
            try Task.checkCancellation()
            try await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
            try Task.checkCancellation()
            guard let claimIntent = try await service.getNextStep(claimIntentId: claimIntent.id) else {
                throw ClaimIntentError.invalidResponse
            }
            try Task.checkCancellation()
            switch claimIntent {
            case let .intent(model):
                self.claimIntent = model
                Task {
                    if displayText != taskModel.description {
                        displayText = nil
                    }
                    await delay(0.4)
                    displayText = taskModel.description
                }
            default:
                break
            }

            try await getNextStep()
        }
    }

    override func accessibilityEditHint() -> String {
        ""
    }
}
