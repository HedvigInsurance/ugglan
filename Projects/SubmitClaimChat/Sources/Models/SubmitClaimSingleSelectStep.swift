import Observation
import SwiftUI
import hCore

final class SubmitClaimSingleSelectStep: ClaimIntentStepHandler {
    @ObservationIgnored private var _selectedOptionId: String?
    var selectedOptionId: String? {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimSingleSelectStep.selectedOptionId)
            return _selectedOptionId
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimSingleSelectStep.selectedOptionId) {
                _selectedOptionId = newValue
            }
        }
    }
    let model: ClaimIntentStepContentSelect
    /// With a default selection the member confirms manually, otherwise picking an option submits the step
    var requiresConfirmation: Bool { model.defaultSelectedId != nil }
    /// Set once an auto submit is scheduled - the first pick is final, so further taps are ignored
    @ObservationIgnored private var _isSelectionLocked = false
    private(set) var isSelectionLocked: Bool {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimSingleSelectStep.isSelectionLocked)
            return _isSelectionLocked
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimSingleSelectStep.isSelectionLocked) {
                _isSelectionLocked = newValue
            }
        }
    }
    private var autoSubmitTask: Task<Void, Never>?

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .singleSelect(let model) = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-single select content")
        }
        self.model = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        self.initializeSelectValues()
    }

    private func initializeSelectValues() {
        selectedOptionId = model.currentSelectedId ?? model.defaultSelectedId
    }

    func select(optionId: String) {
        guard !isSelectionLocked else { return }
        selectedOptionId = optionId
        guard !requiresConfirmation else { return }
        isSelectionLocked = true
        autoSubmitTask = Task { [weak self] in
            await delay(ClaimChatConstants.Timing.autoSubmitDelay)
            guard !Task.isCancelled else { return }
            self?.isSelectionLocked = false
            self?.submitResponse()
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        guard let selectedOptionId else {
            throw ClaimIntentError.invalidInput
        }
        let result = try await service.claimIntentSubmitSelect(
            stepId: claimIntent.currentStep.id,
            selectedValue: selectedOptionId
        )
        guard let result else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }

    override func skip() async {
        autoSubmitTask?.cancel()
        autoSubmitTask = nil
        isSelectionLocked = false
        await super.skip()
        selectedOptionId = nil
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedStep
        }
        guard let selectedOptionId,
            let selectedOption = model.options.first(where: { $0.id == selectedOptionId })
        else {
            return ""
        }
        return .accessibilitySubmittedValue(selectedOption.title)
    }
}

public struct ClaimIntentContentSelectOption: Sendable, Identifiable {
    public let id: String
    let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
