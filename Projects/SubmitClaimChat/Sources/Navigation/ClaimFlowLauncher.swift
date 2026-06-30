import SwiftUI
import hCore
import hCoreUI

extension View {
    public func handleClaimFlow(
        startInput: Binding<StartClaimInput?>,
        onViewDeinit: @escaping () -> Void
    ) -> some View {
        self.modifier(ClaimFlowLauncher(startInput: startInput, onDeinit: onViewDeinit))
    }
}

struct ClaimFlowLauncher: ViewModifier {
    @State var startInputDetent: StartClaimInput?
    @Binding var startInput: StartClaimInput?
    @State private var submitClaimInput: StartClaimInput?
    @State private var router = NavigationRouter()
    @State var disableSubmitChatClaimAnimations = false
    let onDeinit: () -> Void
    func body(content: Content) -> some View {
        content
            .detent(
                item: $startInputDetent,
                presentationStyle: .detent(style: [.height]),
                options: .constant(.alwaysOpenOnTop),
                content: { input in
                    let hasClaimInProgress: Bool = {
                        switch input.type {
                        case let .regular(hasInProgress):
                            return hasInProgress
                        case .inProgress:
                            return true
                        }
                    }()
                    SubmitClaimChatHonestyPledgeScreen(hasOngoingClaim: hasClaimInProgress) {
                        inProgress,
                        withAnimations in
                        startInputDetent = nil
                        disableSubmitChatClaimAnimations = !withAnimations
                        submitClaimInput = inProgress ? .init(type: .inProgress) : startInput
                        startInput = nil
                    }
                    .navigationTitle(L10n.honestyPledgeHeader)
                    .embededInNavigation(
                        options: .navigationType(type: .large),
                        tracking: self
                    )
                }
            )
            .modally(
                item: $submitClaimInput,
                options: .constant([.withoutGrabber, .alwaysOpenOnTop])
            ) { input in
                SubmitClaimFlowNavigation(
                    startInput: .init(
                        input: input,
                        openChat: {
                            NotificationCenter.default.post(
                                name: .openChat,
                                object: ChatType.newConversation
                            )
                        }
                    ),
                    disableAnimations: disableSubmitChatClaimAnimations
                )
                .onDeinit { [onDeinit] in
                    onDeinit()
                }
            }
            .onChange(of: startInput) { value in
                if let value {
                    switch value.type {
                    case .regular:
                        startInputDetent = value
                    case .inProgress:
                        submitClaimInput = value
                        startInput = nil
                    }
                }
            }
    }
}

extension ClaimFlowLauncher: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimChatHonestyPledgeScreen.self)
    }
}
