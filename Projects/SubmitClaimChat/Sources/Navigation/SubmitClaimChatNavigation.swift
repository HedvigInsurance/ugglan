import SwiftUI
import hCoreUI

public struct SubmitClaimChatNavigation: View {
    @StateObject var router = Router()
    @StateObject var viewModel: SubmitClaimChatViewModel

    public init(
        input: StartClaimInput,
        goToClaimDetails: @escaping GoToClaimDetails,
        openChat: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: .init(
                input: input,
                goToClaimDetails: goToClaimDetails,
                openChat: openChat
            )
        )
    }

    public var body: some View {
        RouterHost(router: router, tracking: self) {
            SubmitClaimChatScreen()
                .routerDestination(
                    for: ClaimIntentStepOutcome.self,
                    options: [.hidesBottomBarWhenPushed, .hidesBackButton]
                ) { outcome in
                    SubmitClaimOutcomeScreen(outcome: outcome)
                        .withDismissButton()
                }
                .withDismissButton()
                .embededInNavigation(
                    tracking: self
                )
                .environmentObject(router)
                .environmentObject(viewModel)
        }
    }
}

extension SubmitClaimChatNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SubmitClaimChatScreen.self)
    }
}
