import Claims
import SwiftUI
import hCoreUI

final class SubmitClaimDeflectStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMesageSender { .hedvig }

    let deflectModel: ClaimIntentOutcomeDeflection
    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .deflect(let model) = claimIntent.currentStep.content else {
            fatalError("DeflectStepHandler initialized with non-deflect content")
        }
        self.deflectModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        Task { [weak self] in
            try await Task.sleep(seconds: 0.5)
            self?.state.showResults = true
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        throw ClaimIntentError.invalidResponse
    }
}
