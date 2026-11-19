import AppStateContainer
import Contracts
import Environment
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
    /// The voice claim POC, presented instead of the chat when the member picks "Talk it through".
    @State private var voiceClaimInput: StartClaimInput?
    @AppState private var devSettingsStore: DevSettingsStore
    @AppObservedObject private var featureFlags: FeatureFlagsStore
    let onDeinit: () -> Void
    func body(content: Content) -> some View {
        content
            .detent(
                item: $startInputDetent,
                presentationStyle: .detent(style: [.height]),
                options: .constant(.alwaysOpenOnTop),
                content: { input in
                    SubmitClaimChatHonestyPledgeScreen(
                        onConfirm: {
                            startInputDetent = nil
                            submitClaimInput = input
                        },
                        onConfirmVoice: voiceAgentId == nil
                            ? nil
                            : {
                                startInputDetent = nil
                                voiceClaimInput = input
                            }
                    )
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
            .modally(
                item: $voiceClaimInput,
                options: .constant([.withoutGrabber, .alwaysOpenOnTop])
            ) { _ in
                if let voiceAgentId {
                    VoiceClaimFlowView { makeVoiceViewModel(agentId: voiceAgentId) }
                }
            }
            .onAppear {
                // onChange misses a value set before the view attaches (e.g. cold-start deep link).
                handleStartInput(startInput)
            }
            .onChange(of: startInput) { _, value in
                handleStartInput(value)
            }
            .alert(
                L10n.resumeClaimDraftAlertTitle,
                isPresented: $showDraftAlert
            ) {
                Button(L10n.resumeClaimDraftAlertContinue) {
                    submitClaimInput = .init(type: .inProgress)
                }
                Button(L10n.resumeClaimDraftAlertStartNew, role: .destructive) {
                    handleStartInput(.init(type: .regular(hasInProgress: false)))
                }
            } message: {
                Text(L10n.resumeClaimDraftAlertBody)
            }
    }

    /// The ElevenLabs agent to talk to, when the voice claim POC is on for this member (Unleash, or the dev setting)
    /// and has an agent in this environment.
    private var voiceAgentId: String? {
        let isOn = featureFlags.isVoiceClaimEnabled || devSettingsStore.isVoiceClaimForced
        return isOn ? Environment.current.elevenLabsClaimAgentId : nil
    }

    private func makeVoiceViewModel(agentId: String) -> VoiceClaimViewModel {
        let viewModel = VoiceClaimViewModel(agentId: agentId)
        let contracts: ContractStore = globalAppStateContainer.get()
        let all = contracts.activeContracts + contracts.pendingContracts + contracts.terminatedContracts
        // The engine's policy pickers use agreement ids; keep the contract id too in case a step uses that.
        let kinds: [(String, String)] = all.flatMap { contract -> [(String, String)] in
            guard let kind = PolicyKind.describe(contract.typeOfContract) else { return [] }
            let ids = [contract.id, contract.currentAgreement?.id, contract.upcomingChangedAgreement?.id]
            return ids.compactMap { $0 }.map { ($0, kind) }
        }
        viewModel.setPolicies(Dictionary(kinds, uniquingKeysWith: { first, _ in first }))
        let voiceInput = $voiceClaimInput
        let chatInput = $submitClaimInput
        viewModel.onExit = { exit in
            voiceInput.wrappedValue = nil
            Task { @MainActor in
                // Let the voice modal finish dismissing before the chat is presented.
                try? await Task.sleep(for: .seconds(0.6))
                switch exit {
                case .continueDraftInChat:
                    chatInput.wrappedValue = .init(type: .inProgress)
                case .startInChat:
                    chatInput.wrappedValue = .init(type: .regular(hasInProgress: false))
                }
            }
        }
        return viewModel
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
            }
        case .inProgress:
            submitClaimInput = value
        }
        startInput = nil
    }
}

extension ClaimFlowLauncher: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: SubmitClaimChatHonestyPledgeScreen.self)
    }
}
