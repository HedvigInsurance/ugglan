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
    @InjectObservableObject var featureFlags: FeatureFlags

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
                .navigationTitle(featureFlags.isResumeClaimEnabled ? viewModel.title : L10n.claimChatTitle)
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
                        .claimChatDismissButton(
                            showResumableAlert: false,
                            isResumeClaimEnabled: featureFlags.isResumeClaimEnabled
                        )
                    }
                )
                .claimChatDismissButton(
                    showResumableAlert: viewModel.currentStep?.claimIntent.resumable ?? false,
                    isResumeClaimEnabled: featureFlags.isResumeClaimEnabled
                )
        }
        .environmentObject(viewModel)
        .environmentObject(viewModel.scrollCoordinator)
    }
}

extension View {
    /// Flag ON: alert only when the intent is resumable, with resume-draft copy.
    /// Flag OFF: legacy behavior — always confirm dismissal with the generic claims alert.
    @ViewBuilder
    fileprivate func claimChatDismissButton(showResumableAlert: Bool, isResumeClaimEnabled: Bool) -> some View {
        if isResumeClaimEnabled {
            withDismissButton(
                withAlert: showResumableAlert,
                title: L10n.resumeClaimLeaveTitle,
                message: L10n.resumeClaimLeaveBody,
                confirmButtonTitle: L10n.resumeClaimLeaveConfirm,
                cancelButtonTitle: L10n.resumeClaimLeaveCancel
            )
        } else {
            withAlertDismiss(message: L10n.Claims.Alert.body)
        }
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
