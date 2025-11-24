import SwiftUI

final class SubmitClaimSingleSelectStep: ClaimIntentStepHandler {
    @Published var selectedOption: String?
    let options: [ClaimIntentContentSelectOption]

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .singleSelect(let model) = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-single select content")
        }
        self.options = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntentType {
        guard
            let result = try await service.claimIntentSubmitSelect(
                stepId: claimIntent.currentStep.id,
                selectedValue: selectedOption!
            )
        else {
            throw ClaimIntentError.unknown
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
