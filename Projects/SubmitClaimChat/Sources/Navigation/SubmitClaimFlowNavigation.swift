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
        startInput: SubmitClaimChatInput
    ) {
        _viewModel = StateObject(
            wrappedValue: .init(startInput: startInput)
        )
    }

    public var body: some View {
        hNavigationStack(router: viewModel.router, options: [.extendedNavigationWidth], tracking: self) {
            SubmitClaimChatScreen()
                .navigationTitle(L10n.claimChatTitle)
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
        .environmentObject(viewModel.scrollCoordinator)
    }
}

extension SubmitClaimFlowNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SubmitClaimChatScreen.self)
    }
}

extension View {
    func addDismissClaimChatFlow() -> some View {
        withAlertDismiss(message: L10n.Claims.Alert.body)
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

extension ClaimIntentStepOutcome: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimSuccessView.self)
    }
}
