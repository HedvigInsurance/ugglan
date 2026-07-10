import SwiftUI
import hCore

final class SubmitClaimInformationStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMessageSender { .hedvig }

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
        Task { [weak self] in
            try await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
            self?.state.showResults = true
            if let self, self.informationModel.severity == .critical {
                UIAccessibility.post(notification: .announcement, argument: self.informationModel.notice)
            }
        }
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
