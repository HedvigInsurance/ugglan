import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatInput: Equatable, Identifiable {
    let input: StartClaimInput
    let openChat: () -> Void

    public init(
        input: StartClaimInput,
        openChat: @escaping () -> Void
    ) {
        self.input = input
        self.openChat = openChat
    }

    public var id = UUID().uuidString
    public static func == (lhs: SubmitClaimChatInput, rhs: SubmitClaimChatInput) -> Bool {
        lhs.id == rhs.id
    }
}

struct SubmitClaimFlowNavigation: View {
    @StateObject var viewModel: SubmitClaimChatViewModel

    init(
        startInput: SubmitClaimChatInput,
        disableAnimations: Bool
    ) {
        disableSubmitChatClaimAnimations = disableAnimations
        _viewModel = StateObject(
            wrappedValue: .init(startInput: startInput)
        )
    }

    public var body: some View {
        hNavigationStack(router: viewModel.router, options: [.extendedNavigationWidth], tracking: self) {
            SubmitClaimChatScreen()
                .navigationTitle(viewModel.title)
                .routerDestination(
                    for: ClaimIntentStepOutcome.self,
                    options: [.hidesBottomBarWhenPushed, .hidesBackButton]
                ) { outcome in
                    SubmitClaimOutcomeScreen(outcome: outcome)
                        .onDeinit {
                            NotificationCenter.default.post(name: .claimCreated, object: nil)
                        }
                        .withDismissButton()
                }
                .routerDestination(
                    for: Deflection.self,
                    destination: { model in
                        SubmitClaimDeflectScreen(model: model) { [weak viewModel] in
                            viewModel?.openChat()
                        }
                        .withDismissButton()
                    }
                )
                .withDismissButton(
                    withAlert: viewModel.currentStep?.claimIntent.resumable ?? false,
                    title: "Leave claim?",  //L10n.claimChatLeaveTitle
                    message: "Your claim is automatically saved for 7 days.",  //L10n.claimChatLeaveBody
                    confirmButtonTitle: "Yes, leave",  //L10n.claimChatLeaveConfirm
                    cancelButtonTitle: "No"  //L10n.General.no
                )
        }
        .environmentObject(viewModel)
        .environmentObject(viewModel.scrollCoordinator)
    }
}

extension SubmitClaimFlowNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SubmitClaimChatScreen.self)
    }
}

extension Deflection: TrackingViewNameProtocol, NavigationTitleProtocol {
    public var navigationTitle: String? {
        title
    }

    public var nameForTracking: String {
        String(describing: SubmitClaimDeflectScreen.self)
    }
}

extension ClaimIntentStepOutcome: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimSuccessView.self)
    }
}
