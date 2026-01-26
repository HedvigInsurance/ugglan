import Foundation

@MainActor
class ClaimIntentFlowManager {
    private let service: ClaimIntentService

    init(service: ClaimIntentService) {
        self.service = service
    }

    func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        try await service.startClaimIntent(input: input)
    }

    func createStepHandler(
        for claimIntent: ClaimIntent,
        alertVm: SubmitClaimChatScreenAlertViewModel,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) -> ClaimIntentStepHandler {
        ClaimIntentStepHandlerFactory.createHandler(
            for: claimIntent,
            service: service,
            alertVm: alertVm,
            mainHandler: mainHandler
        )
    }
}
