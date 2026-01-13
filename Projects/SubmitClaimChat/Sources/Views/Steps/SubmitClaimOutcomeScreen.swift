import SwiftUI
import hCoreUI

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
        case let .claim(model):
            SubmitClaimSuccessView(model: model)
        case .unknown:
            EmptyView()
        }
    }
}
