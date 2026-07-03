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
    @State private var showDraftAlert = false
    let onDeinit: () -> Void
    func body(content: Content) -> some View {
        content
            .detent(
                item: $startInputDetent,
                presentationStyle: .detent(style: [.height]),
                options: .constant(.alwaysOpenOnTop),
                content: { input in
                    SubmitClaimChatHonestyPledgeScreen {
                        inProgress,
                        withAnimations in
                        startInputDetent = nil
                        disableSubmitChatClaimAnimations = !withAnimations
                        submitClaimInput = inProgress ? .init(type: .inProgress) : input
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
                    case let .regular(hasInProgress):
                        if hasInProgress {
                            // A saved draft exists — let the member choose before starting a new claim.
                            showDraftAlert = true
                        } else {
                            startInputDetent = value
                        }
                    case .inProgress:
                        submitClaimInput = value
                        startInput = nil
                    }
                }
            }
            .alert(
                "You have a draft claim",  //L10n.claimDraftAlertTitle
                isPresented: $showDraftAlert
            ) {
                Button("Continue draft") {  //L10n.claimDraftAlertContinue
                    submitClaimInput = .init(type: .inProgress)
                    startInput = nil
                }
                Button("Start new claim", role: .destructive) {  //L10n.claimDraftAlertStartNew
                    startInputDetent = .init(type: .regular(hasInProgress: false))
                    startInput = nil
                }
            } message: {
                Text("Starting a new claim will delete your saved draft")  //L10n.claimDraftAlertBody
            }
    }
}

extension ClaimFlowLauncher: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimChatHonestyPledgeScreen.self)
    }
}
