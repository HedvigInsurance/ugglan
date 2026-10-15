import Foundation
import Observation
import SwiftUI
import hCore
import hCoreUI

@MainActor
class ClaimIntentStepHandler: Observable, @MainActor Identifiable {
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
        var isLoaderAnimating = true
        var showLoadingAnimation = true
    }

    // Observation is wired by hand instead of with @Observable because the macro only
    // transforms the properties of the class it is attached to. Every property declared in
    // one of this class's subclasses would stop updating the UI, with nothing to compile
    // against. The registrar is shared with the subclasses for that reason.
    let observationRegistrar = ObservationRegistrar()

    @ObservationIgnored private var _state = StepUIState()
    var state: StepUIState {
        get {
            observationRegistrar.access(self, keyPath: \ClaimIntentStepHandler.state)
            return _state
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \ClaimIntentStepHandler.state) {
                _state = newValue
            }
        }
    }
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent
    var sender: SubmitClaimChatMessageSender { .member }
    var isSkippable: Bool { claimIntent.isSkippable }
    var isRegrettable: Bool { claimIntent.isRegrettable }
    var usesFloatingInputCard: Bool { false }

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
        if let self = self as? SubmitClaimInformationStep {
            return self.informationModel.notice
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
                await delay(ClaimChatConstants.Timing.shortDelay)
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
            } catch is CancellationError {
                return
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
                state.isEnabled = true
                state.isLoading = false
            }
        }
    }

    func skip() async {
        state.isLoading = true
        state.isEnabled = false
        defer {
            state.isEnabled = true
            state.isLoading = false
        }
        try? await Task.sleep(for: .seconds(ClaimChatConstants.Timing.skipDelay))
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
            showErrorAlert(for: ex) { [weak self] in
                await self?.skip()
            }
        }
    }

    func cancelOngoingWork() {
        submitTask?.cancel()
        submitTask = nil
    }

    // describe entered values for accessibility
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
                mainHandler(.regret(currentClaimIntent: claimIntent, newClaimIntent: model))
            case .outcome:
                break
            }
        } catch let ex {
            showErrorAlert(for: ex) { [weak self] in
                await self?.regret()
            }
        }
    }

    deinit {
        submitTask?.cancel()
        submitTask = nil
    }

    /// Shows an error alert with retry action
    private func showErrorAlert(
        for error: Error,
        retryAction: @escaping () async -> Void
    ) {
        alertVm?.alertModel = .init(
            type: .error,
            message: error.localizedDescription,
            action: {
                Task {
                    await retryAction()
                }
            }
        )
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
        case .deflectMessage:
            handler = SubmitClaimDeflectMessageStep(
                claimIntent: claimIntent,
                service: service,
                mainHandler: mainHandler
            )
        case .information:
            handler = SubmitClaimInformationStep(
                claimIntent: claimIntent,
                service: service,
                mainHandler: mainHandler
            )
        }
        handler.alertVm = alertVm
        return handler
    }
}

enum SubmitClaimEvent {
    case goToNext(claimIntent: ClaimIntent)
    case regret(currentClaimIntent: ClaimIntent, newClaimIntent: ClaimIntent)
    case removeStep(id: String)
    case outcome(model: ClaimIntentStepOutcome)
}

// MARK: - Errors
public enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
    case unknownStep
    case unknownField
    case error(message: String)
}

extension ClaimIntentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return L10n.claimChatErrorMessage
        case .invalidResponse:
            return ""
        case .unknownStep:
            return L10n.embarkUpdateAppBody
        case .unknownField:
            return L10n.embarkUpdateAppBody
        case let .error(message): return message
        }
    }
}
