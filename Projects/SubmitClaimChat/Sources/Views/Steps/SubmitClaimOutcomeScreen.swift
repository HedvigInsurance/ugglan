import SwiftUI
import hCoreUI

public typealias GoToClaimDetails = (String) -> Void

public struct SubmitClaimOutcomeScreen: View {
    let outcome: ClaimIntentStepOutcome
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void

    public init(
        outcome: ClaimIntentStepOutcome,
        goToClaimDetails: @escaping GoToClaimDetails,
        openChat: @escaping () -> Void
    ) {
        self.outcome = outcome
        self.goToClaimDetails = goToClaimDetails
        self.openChat = openChat
    }

    public var body: some View {
        switch outcome {
        case let .deflect(model):
            SubmitClaimDeflectScreen(
                model: model,
                openChat: {
                    openChat()
                }
            )
        case let .claim(model):
            VStack(spacing: .padding16) {
                hText("Your claim was submitted successfully")
                hButton(.medium, .secondary, content: .init(title: "Go to claim")) {
                    goToClaimDetails(model.claimId)
                }
            }
        case .unknown:
            EmptyView()
        }
    }
}
