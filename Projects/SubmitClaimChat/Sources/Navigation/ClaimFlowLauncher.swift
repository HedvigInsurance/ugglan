import SwiftUI
import hCore
import hCoreUI

extension View {
    public func handleClaimFlow(
        startInput: Binding<StartClaimInput?>
    ) -> some View {
        self.modifier(ClaimFlowLauncher(startInput: startInput))
    }
}

struct ClaimFlowLauncher: ViewModifier {
    @Binding var startInput: StartClaimInput?
    @State private var submitClaimInput: StartClaimInput?
    @State private var router = Router()
    @State var disableSubmitChatClaimAnimations = false
    func body(content: Content) -> some View {
        content
            .detent(
                item: $startInput,
                presentationStyle: .detent(style: [.height]),
                content: { input in
                    SubmitClaimChatHonestyPledgeScreen { withAnimations in
                        disableSubmitChatClaimAnimations = !withAnimations
                        submitClaimInput = startInput
                        startInput = nil
                    }
                    .configureTitle(L10n.honestyPledgeHeader)
                    .embededInNavigation(
                        options: .navigationType(type: .large),
                        tracking: self
                    )
                }
            )
            .modally(
                item: $submitClaimInput,
                options: .constant(.withoutGrabber)
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
            }
    }
}

extension ClaimFlowLauncher: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimChatHonestyPledgeScreen.self)
    }
}
