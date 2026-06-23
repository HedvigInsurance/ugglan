import SwiftUI
import hCoreUI

final class SubmitClaimDeflectMessageStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMessageSender { .hedvig }

    let deflectMessageModel: ClaimIntentStepContentDeflectionMessage

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .deflectMessage(let model) = claimIntent.currentStep.content else {
            fatalError("DeflectMessageStepHandler initialized with non-deflectMessage content")
        }
        self.deflectMessageModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        Task { [weak self] in
            try await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
            self?.state.showResults = true
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        throw ClaimIntentError.invalidResponse
    }

    override func accessibilityEditHint() -> String {
        ""
    }
}
