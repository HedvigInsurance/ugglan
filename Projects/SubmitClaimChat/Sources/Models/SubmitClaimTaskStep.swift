import SwiftUI

final class SubmitClaimTaskStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent {
        didSet {
            if case let .task(model) = claimIntent.currentStep.content {
                withAnimation {
                    taskModel = model
                }
            }
        }
    }
    let sender: SubmitClaimChatMesageSender = .hedvig
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true

    @Published var taskModel: ClaimIntentStepContentTask
    private let service: ClaimIntentService
    private let mainHandler: (ClaimIntent) -> Void

    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
        guard case .task(let model) = claimIntent.currentStep.content else {
            fatalError("TaskStepHandler initialized with non-task content")
        }
        self.taskModel = model
        Task {
            try await Task.sleep(seconds: 1)
            _ = try await submitResponse()
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
            try await Task.sleep(seconds: 1)
            let claimIntent = try await service.getNextStep(claimIntentId: claimIntent.id)
            self.claimIntent = claimIntent
            try await getNextStep()
        }
    }
}
