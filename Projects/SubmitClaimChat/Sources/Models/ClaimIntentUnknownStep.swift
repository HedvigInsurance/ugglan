final class SubmitClaimUnknownStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMesageSender { .hedvig }

    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func submitResponse() async throws -> ClaimIntent {
        throw ClaimIntentError.unknown
    }
}
