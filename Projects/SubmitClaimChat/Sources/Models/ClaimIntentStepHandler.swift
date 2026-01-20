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
        var disableSkip = false
        var showInput = false
        var animateText = true
    }

    @Published var state = StepUIState()
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent
    var sender: SubmitClaimChatMesageSender { .member }
    var isSkippable: Bool { claimIntent.isSkippable }
    var isRegrettable: Bool { claimIntent.isRegrettable }

    let service: ClaimIntentService
    let mainHandler: (SubmitClaimEvent) -> Void
    weak var alertVm: SubmitClaimChatScreenAlertViewModel?
    private var submitTask: Task<Void, Never>?

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
        if getText() == nil {
            state.showInput = true
        }
    }

    func setDisableSkip(to disabled: Bool) {
        state.disableSkip = disabled
    }

    func validateInput() -> Bool {
        true
    }

    func executeStep() async throws -> ClaimIntentType {
        fatalError("submitResponse must be overridden")
    }

    func getText() -> String? {
        if let text = claimIntent.currentStep.text {
            if let hint = claimIntent.hint {
                return text + "\n\n" + hint
            }
            return text
        }
        return nil
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
                try Task.checkCancellation()
                let result = try await executeStep()
                try Task.checkCancellation()
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
            alertVm?.alertModel = .init(
                type: .error,
                message: ex.localizedDescription,
                action: { [weak self] in
                    Task {
                        await self?.skip()
                    }
                }
            )
        }
    }

    // describe entered values for acacessibility
    func accessibilityEditHint() -> String {
        fatalError("accessibilityEditHint must be overridden")
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
            alertVm?.alertModel = .init(
                type: .error,
                message: ex.localizedDescription,
                action: { [weak self] in
                    Task {
                        await self?.regret()
                    }
                }
            )
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
        alertVm: SubmitClaimChatScreenAlertViewModel,
        mainHandler: @escaping ((SubmitClaimEvent) -> Void)
    ) -> ClaimIntentStepHandler {
        let handler: ClaimIntentStepHandler
        switch claimIntent.currentStep.content {
        case .form:
            handler = SubmitClaimFormStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .task:
            handler = SubmitClaimTaskStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .audioRecording:
            handler = SubmitClaimAudioStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .summary:
            handler = SubmitClaimSummaryStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .singleSelect:
            handler = SubmitClaimSingleSelectStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .fileUpload:
            handler = SubmitClaimFileUploadStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .deflect:
            handler = SubmitClaimDeflectStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .unknown:
            handler = SubmitClaimUnknownStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        }
        handler.alertVm = alertVm
        return handler
    }
}

enum SubmitClaimEvent {
    case goToNext(claimIntent: ClaimIntent)
    case regret(currentClaimIntent: ClaimIntent, newclaimIntent: ClaimIntent)
    case removeStep(id: String)
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
            return L10n.claimChatErrorMessage
        case .invalidResponse:
            return ""
        case let .error(message): return message
        }
    }
}
