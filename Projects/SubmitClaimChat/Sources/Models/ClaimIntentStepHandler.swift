import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
class ClaimIntentStepHandler: ObservableObject, @MainActor Identifiable {
    struct StepUIState {
        var isLoading = false
        var isEnabled = true
        var error: Error? {
            didSet {
                showError = error != nil
            }
        }
        var isStepExecuted = false
        var isSkipped = false
        var showError = false
        var showResults = false
    }

    @Published var state = StepUIState()
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent
    var sender: SubmitClaimChatMesageSender { .member }
    var isSkippable: Bool { claimIntent.isSkippable }
    var isRegrettable: Bool { claimIntent.isRegrettable }
    var showText: Bool { claimIntent.currentStep.showText }

    let service: ClaimIntentService
    let mainHandler: (SubmitClaimEvent) -> Void
    private var submitTask: Task<Void, Never>?

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
    }

    func validateInput() -> Bool {
        true
    }

    func executeStep() async throws -> ClaimIntentType {
        fatalError("submitResponse must be overridden")
    }

    final func submitResponse() {
        submitTask?.cancel()

        submitTask = Task { [weak self] in
            guard let self = self else { return }
            UIApplication.dismissKeyboard()

            let hasError = state.error != nil
            state.isLoading = true
            state.isEnabled = false
            state.error = nil

            if hasError {
                try? await Task.sleep(seconds: 0.5)
            }
            do {
                let result = try await executeStep()
                state.isStepExecuted = true
                state.showResults = true
                switch result {
                case let .intent(model):
                    mainHandler(.goToNext(claimIntent: model))
                case let .outcome(model):
                    mainHandler(.outcome(model: model))
                }
                state.isLoading = false
            } catch let error {
                if let error = error as? ClaimIntentError {
                    switch error {
                    case .invalidInput:
                        state.isEnabled = true
                    default:
                        self.state.error = error
                    }
                } else {
                    self.state.error = error
                }
            }
        }
    }

    func skip() async {
        state.isLoading = true
        state.isEnabled = false
        defer {
            state.isLoading = false
        }
        do {
            let result = try await service.claimIntentSkipStep(stepId: id)
            state.isSkipped = true
            state.isStepExecuted = true
            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            switch result {
            case let .intent(model):
                mainHandler(.goToNext(claimIntent: model))
            case let .outcome(model):
                mainHandler(.outcome(model: model))
            }
        } catch let ex {
            self.state.error = ex
        }
    }

    func regret() async {
        state.isLoading = true
        state.isEnabled = false
        defer {
            state.isEnabled = true
            state.isLoading = false
        }

        do {
            let result = try await service.claimIntentRegretStep(stepId: id)
            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            state.isLoading = false
            state.isEnabled = false

            switch result {
            case let .intent(model):
                mainHandler(.regret(currentClaimIntent: claimIntent, newclaimIntent: model))
            case .outcome:
                break
            }
        } catch let ex {
            self.state.error = ex
        }
    }

    deinit {
        submitTask?.cancel()
        submitTask = nil
    }
}

enum ClaimIntentStepHandlerFactory {
    @MainActor
    static func createHandler(
        for claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping ((SubmitClaimEvent) -> Void)
    ) -> ClaimIntentStepHandler {
        switch claimIntent.currentStep.content {
        case .form:
            return SubmitClaimFormStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .task:
            return SubmitClaimTaskStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .audioRecording:
            return SubmitClaimAudioStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .summary:
            return SubmitClaimSummaryStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .singleSelect:
            return SubmitClaimSingleSelectStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .fileUpload:
            return SubmitClaimFileUploadStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .unknown:
            return SubmitClaimUnknownStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        }
    }
}

enum SubmitClaimEvent {
    case goToNext(claimIntent: ClaimIntent)
    case regret(currentClaimIntent: ClaimIntent, newclaimIntent: ClaimIntent)
    case outcome(model: ClaimIntentStepOutcome)
}

// MARK: - Errors
public enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
    case error(message: String)
}

extension ClaimIntentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Make sure you fill in all the required fields."
        case .invalidResponse:
            return "message"
        case let .error(message): return message
        }
    }
}
