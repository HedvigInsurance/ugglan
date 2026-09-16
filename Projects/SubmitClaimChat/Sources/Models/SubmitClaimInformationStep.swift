import SwiftUI
import hCoreUI

final class SubmitClaimInformationStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMessageSender { .member }

    let informationModel: ClaimIntentStepContentInformation

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .information(let model) = claimIntent.currentStep.content else {
            fatalError("InformationStepHandler initialized with non-information content")
        }
        self.informationModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntentType {
        guard let result = try await service.claimIntentSubmitInformation(stepId: claimIntent.currentStep.id) else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }

    override func accessibilityEditHint() -> String {
        ""
    }
}
