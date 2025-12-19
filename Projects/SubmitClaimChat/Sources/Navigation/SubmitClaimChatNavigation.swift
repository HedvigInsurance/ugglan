import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatNavigation: View {
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
        RouterHost(router: viewModel.router, options: [.extendedNavigationWidth], tracking: self) {
            SubmitClaimChatScreen()
                .routerDestination(
                    for: ClaimIntentStepOutcome.self,
                    options: [.hidesBottomBarWhenPushed, .hidesBackButton]
                ) { outcome in
                    SubmitClaimOutcomeScreen(outcome: outcome)
                        .addDismissClaimChatFlow()
                }
                .routerDestination(
                    for: ClaimIntentOutcomeDeflection.self,
                    destination: { model in
                        SubmitClaimDeflectScreen(model: model) { [weak viewModel] in
                            viewModel?.openChat()
                        }
                        .addDismissClaimChatFlow()
                    }
                )
                .addDismissClaimChatFlow()
        }
        .environmentObject(viewModel)
    }
}

extension SubmitClaimChatNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SubmitClaimChatScreen.self)
    }
}

extension View {
    func addDismissClaimChatFlow() -> some View {
        withAlertDismiss(message: L10n.claimChatEditExplanation)
    }
}

extension ClaimIntentOutcomeDeflection: TrackingViewNameProtocol, NavigationTitleProtocol {
    public var navigationTitle: String? {
        title
    }

    public var nameForTracking: String {
        String(describing: SubmitClaimDeflectScreen.self)
    }
}
