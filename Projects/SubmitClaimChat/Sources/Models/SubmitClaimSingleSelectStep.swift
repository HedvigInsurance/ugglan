import SwiftUI
import hCore

final class SubmitClaimSingleSelectStep: ClaimIntentStepHandler {
    @Published var selectedOptionId: String?
    let model: ClaimIntentStepContentSelect

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
        selectedOptionId = model.defaultSelectedId
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
        await super.skip()
        selectedOptionId = nil
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedLabel
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
