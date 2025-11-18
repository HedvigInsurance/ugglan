import SwiftUI

final class SubmitClaimSingleSelectStep: ClaimIntentStepHandler {
    @Published var selectedOption: String?
    let options: [ClaimIntentContentSelectOption]

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (ClaimIntent, Bool) -> Void
    ) {
        guard case .singleSelect(let model) = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-single select content")
        }
        self.options = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func submitResponse() async throws -> ClaimIntent {
        withAnimation {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }

        // Acknowledge text step and get next step
        guard
            let result = try await service.claimIntentSubmitSelect(
                stepId: claimIntent.currentStep.id,
                selectedValue: selectedOption!
            )
        else {
            throw ClaimIntentError.unknown
        }
        mainHandler(result, false)
        withAnimation {
            isEnabled = false
        }
        return result
    }

    override func skip() async throws -> ClaimIntent {
        let data = try await super.skip()
        selectedOption = nil
        return data
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
