import SwiftUI

final class SubmitClaimSingleSelectStep: ClaimIntentStepHandler {
    @Published var selectedOption: String?
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
        selectedOption = model.defaultSelectedId
    }

    override func executeStep() async throws -> ClaimIntentType {
        guard let selectedOption else {
            throw ClaimIntentError.invalidInput
        }
        let result = try await service.claimIntentSubmitSelect(
            stepId: claimIntent.currentStep.id,
            selectedValue: selectedOption
        )
        guard let result else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }

    override func skip() async {
        await super.skip()
        selectedOption = nil
    }
}

public struct ClaimIntentContentSelectOption: Sendable {
    let id: String
    let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
