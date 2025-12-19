import SwiftUI
import hCore
import hCoreUI

public struct SubmiClaimChatInput: Equatable, Identifiable {
    let input: StartClaimInput
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void

    public var id = UUID().uuidString
    public static func == (lhs: SubmiClaimChatInput, rhs: SubmiClaimChatInput) -> Bool {
        lhs.id == rhs.id
    }
}

private class SubmitClaimChatSelectNavigationViewModel: ObservableObject {
    @Published var isClaimsFlowPresented: SubmiClaimChatInput?
}

public struct SubmitClaimChatSelectNavigation: View {
    @StateObject private var claimsSelectNavigationVm = SubmitClaimChatSelectNavigationViewModel()
    @StateObject var claimsRouter = Router()
    @State private var measuredHeight: CGFloat = 0
    @State var shouldHideSelectFlow = false
    let sourceMessageId: String?
    let goToClaimDetails: GoToClaimDetails
    var openChat: () -> Void

    public init(
        sourceMessageId: String?,
        goToClaimDetails: @escaping GoToClaimDetails,
        openChat: @escaping () -> Void
    ) {
        self.sourceMessageId = sourceMessageId
        self.goToClaimDetails = goToClaimDetails
        self.openChat = openChat
    }

    public var body: some View {
        RouterHost(router: claimsRouter, options: [.extendedNavigationWidth], tracking: self) {
            SubmitClaimSelectFlowScreen { claimAction in
                presentClaimsFlow(withDevFlow: claimAction == .devAutomationSubmitClaim)
            }
            .hidden($shouldHideSelectFlow)
        }
        .modally(
            item: $claimsSelectNavigationVm.isClaimsFlowPresented
        ) { startInput in
            SubmitClaimChatNavigation(startInput: startInput)
                .onAppear {
                    shouldHideSelectFlow = true
                }
        }
        .onChange(of: claimsSelectNavigationVm.isClaimsFlowPresented) { presented in
            if presented == nil {
                claimsRouter.dismiss()
            }
        }
    }

    private func presentClaimsFlow(withDevFlow: Bool) {
        DispatchQueue.main.async { [weak claimsSelectNavigationVm] in
            claimsSelectNavigationVm?.isClaimsFlowPresented = .init(
                input: .init(sourceMessageId: sourceMessageId, devFlow: withDevFlow),
                goToClaimDetails: goToClaimDetails,
                openChat: openChat
            )
        }
    }
}

extension SubmitClaimChatSelectNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SubmitClaimSelectFlowScreen.self)
    }
}

struct SubmitClaimChatNavigation: View {
    @StateObject var viewModel: SubmitClaimChatViewModel

    init(
        startInput: SubmiClaimChatInput
    ) {
        _viewModel = StateObject(
            wrappedValue: .init(startInput: startInput)
        )
    }

    var body: some View {
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
