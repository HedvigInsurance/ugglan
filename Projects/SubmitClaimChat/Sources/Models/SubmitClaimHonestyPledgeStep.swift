import Claims
import SwiftUI
import hCoreUI

final class SubmitClaimHonestyPledgeStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMesageSender { .member }

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntentType {
        throw ClaimIntentError.invalidResponse
    }

    func startFlow() {
        state.isStepExecuted = true
        state.showResults = true
    }
}
