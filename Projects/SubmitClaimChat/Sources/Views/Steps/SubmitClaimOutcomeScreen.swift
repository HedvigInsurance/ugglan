import SwiftUI
import hCoreUI

public typealias GoToClaimDetails = (String) -> Void

public struct SubmitClaimOutcomeScreen: View {
    let outcome: ClaimIntentStepOutcome
    @EnvironmentObject var navigationVm: SubmitClaimChatViewModel

    public init(
        outcome: ClaimIntentStepOutcome
    ) {
        self.outcome = outcome
    }

    public var body: some View {
        switch outcome {
        case let .deflect(model):
            SubmitClaimDeflectScreen(
                model: model,
                openChat: { navigationVm.openChat() }
            )
        case let .claim(model):
            VStack(spacing: .padding16) {
                hText("Your claim was submitted successfully")
                hButton(.medium, .secondary, content: .init(title: "Go to claim")) {
                    navigationVm.goToClaimDetails(model.claimId)
                }
            }
        case .unknown:
            EmptyView()
        }
    }
}
