import SwiftUI
import hCore

final class SubmitClaimSingleSelectStep: ClaimIntentStepHandler {
    @Published var selectedOptionId: String?
    let model: ClaimIntentStepContentSelect
    /// With a default selection the member confirms manually, otherwise picking an option submits the step
    var requiresConfirmation: Bool { model.defaultSelectedId != nil }
    /// Set once an auto submit is scheduled - the first pick is final, so further taps are ignored
    @Published private(set) var isSelectionLocked = false
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
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.autoSubmitDelay)
            guard !Task.isCancelled else { return }
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
