import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
class ClaimIntentStepHandler: ObservableObject, @MainActor Identifiable {
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent
    var sender: SubmitClaimChatMesageSender { .member }
    var isSkippable: Bool { claimIntent.isSkippable }
    var isRegrettable: Bool { claimIntent.isRegrettable }
    var showText: Bool { claimIntent.currentStep.showText }

    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    @Published var isStepExecuted = false
    @Published var isSkipped = false
    @Published var showError = false
    @Published var showResults = false
    let service: ClaimIntentService
    let mainHandler: (SubmitClaimEvent) -> Void

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

    private var submitTask: Task<(), Never>?
    final func submitResponse() {
        let submitTask = Task { [weak self] in
            guard let self = self else { return }
            UIApplication.dismissKeyboard()
            let hasError = error != nil
            isLoading = true
            isEnabled = false
            error = nil
            showError = false
            if hasError {
                try? await Task.sleep(seconds: 0.5)
            }
            defer {
                isEnabled = self.error != nil
                isLoading = false
            }
            do {
                let result = try await executeStep()
                isStepExecuted = true
                showResults = true
                switch result {
                case let .intent(model):
                    mainHandler(.goToNext(claimIntent: model))
                case let .outcome(model):
                    mainHandler(.outcome(model: model))
                }
            } catch let error {
                self.error = error
            }
        }
    }

    func skip() async {
        isLoading = true
        isEnabled = false
        defer {
            isLoading = false
        }
        do {
            let result = try await service.claimIntentSkipStep(stepId: id)
            isSkipped = true
            isStepExecuted = true
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
            self.error = ex
        }
    }

    func regret() async {
        isLoading = true
        isEnabled = false
        defer {
            isEnabled = true
            isLoading = false
        }

        do {
            let result = try await service.claimIntentRegretStep(stepId: id)
            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            isLoading = false
            isEnabled = false

            switch result {
            case let .intent(model):
                mainHandler(.regret(currentClaimIntent: claimIntent, newclaimIntent: model))
            case .outcome:
                break
            }
        } catch let ex {
            self.error = ex
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
