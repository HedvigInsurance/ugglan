import AppStateContainer
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
    @State private var showDraftAlert = false
    @AppState private var devSettingsStore: DevSettingsStore
    let onDeinit: () -> Void
    func body(content: Content) -> some View {
        content
            .detent(
                item: $startInputDetent,
                presentationStyle: .detent(style: [.height]),
                options: .constant(.alwaysOpenOnTop),
                content: { input in
                    SubmitClaimChatHonestyPledgeScreen {
                        startInputDetent = nil
                        submitClaimInput = input
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
                    disableAnimations: !devSettingsStore.isSubmitClaimAnimationsEnabled
                )
                .onDeinit { [onDeinit] in
                    onDeinit()
                }
            }
            .onAppear {
                // onChange misses a value set before the view attaches (e.g. cold-start deep link).
                handleStartInput(startInput)
            }
            .onChange(of: startInput) { value in
                handleStartInput(value)
            }
            .alert(
                L10n.resumeClaimDraftAlertTitle,
                isPresented: $showDraftAlert
            ) {
                Button(L10n.resumeClaimDraftAlertContinue) {
                    submitClaimInput = .init(type: .inProgress)
                    startInput = nil
                }
                Button(L10n.resumeClaimDraftAlertStartNew, role: .destructive) {
                    handleStartInput(.init(type: .regular(hasInProgress: false)))
                    startInput = nil
                }
            } message: {
                Text(L10n.resumeClaimDraftAlertBody)
            }
    }

    private func handleStartInput(_ value: StartClaimInput?) {
        guard let value else { return }
        switch value.type {
        case let .regular(hasInProgress):
            if hasInProgress {
                // A saved draft exists — let the member choose before starting a new claim.
                showDraftAlert = true
            } else if devSettingsStore.isSubmitClaimAnimationsEnabled {
                startInputDetent = value
            } else {
                // Dev setting: with animations off, skip the honesty pledge and open the flow directly.
                submitClaimInput = value
                startInput = nil
            }
        case .inProgress:
            submitClaimInput = value
            startInput = nil
        }
    }
}

extension ClaimFlowLauncher: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimChatHonestyPledgeScreen.self)
    }
}
