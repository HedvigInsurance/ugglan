import SwiftUI
import hCore
import hCoreUI

/// The voice claim flow: the orb screen, then the existing success screen once the claim is submitted.
struct VoiceClaimFlowView: View {
    /// Made once, on appear: a view model owns a live call, so it must not be rebuilt with every render.
    let makeViewModel: () -> VoiceClaimViewModel
    @State private var viewModel: VoiceClaimViewModel?

    var body: some View {
        if let viewModel {
            flow(viewModel)
        } else {
            Color.clear.onAppear { viewModel = makeViewModel() }
        }
    }

    private func flow(_ viewModel: VoiceClaimViewModel) -> some View {
        hNavigationStack(router: viewModel.router, options: [.extendedNavigationWidth], tracking: self) {
            VoiceClaimScreen(viewModel: viewModel)
                .navigationTitle(VoiceClaimStrings.title)
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
        }
        // However the flow goes away, the call must not keep the microphone.
        .onDisappear { Task { await viewModel.session.end() } }
    }
}

extension VoiceClaimFlowView: TrackingViewNameProtocol {
    var nameForTracking: String {
        String(describing: VoiceClaimScreen.self)
    }
}

/// Just the orb, like a phone call: what Hedvig is doing in one line, and mute, end, switch to typing.
struct VoiceClaimScreen: View {
    @Bindable var viewModel: VoiceClaimViewModel
    static let night = Color(red: 0.05, green: 0.047, blue: 0.043)

    var body: some View {
        VStack(spacing: .padding24) {
            Spacer()
            VoiceOrbView(status: viewModel.status, isBusy: viewModel.isBusy, levels: viewModel.session.audioLevels)
                // Bigger than the pillow itself (64% at rest), so its glow and turning corners have room.
                .frame(maxWidth: 400)
                .aspectRatio(1, contentMode: .fit)
                .accessibilityElement()
                .accessibilityLabel(VoiceClaimStrings.orbAccessibilityLabel)
                .accessibilityValue(statusText)
            hText(statusText, style: .body1)
                .foregroundColor(hTextColor.Opaque.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .padding32)
                .accessibilityHidden(true)
            Spacer()
            controls
        }
        .frame(maxWidth: .infinity)
        // A call screen: dark, like the orb's night sky. The design system follows the environment's scheme.
        .background(Self.night.ignoresSafeArea())
        .environment(\.colorScheme, .dark)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task { await viewModel.start() }
        .detent(presented: uploadPresented, presentationStyle: .detent(style: [.large])) {
            if let step = viewModel.uploadStep {
                VoiceClaimUploadSheet(step: step) { viewModel.photosPicked(step) }
            }
        }
        .detent(presented: summaryPresented, presentationStyle: .detent(style: [.large])) {
            if let step = viewModel.summaryStep {
                VoiceClaimSummarySheet(step: step)
            }
        }
    }

    private var statusText: String {
        if viewModel.phase == .failed { return VoiceClaimStrings.callEnded }
        if viewModel.isMuted { return VoiceClaimStrings.muted }
        switch viewModel.status {
        case .idle, .connecting: return VoiceClaimStrings.connecting
        case .listening: return VoiceClaimStrings.listening
        case .thinking: return VoiceClaimStrings.thinking
        case .speaking: return VoiceClaimStrings.speaking
        case .ended, .failed: return viewModel.phase == .finished ? "" : VoiceClaimStrings.callEnded
        }
    }

    @ViewBuilder
    private var controls: some View {
        hSection {
            VStack(spacing: .padding8) {
                if viewModel.phase == .failed {
                    hButton(.large, .primary, content: .init(title: VoiceClaimStrings.switchToTyping)) {
                        viewModel.switchToTyping()
                    }
                    hButton(.large, .ghost, content: .init(title: L10n.generalCloseButton)) {
                        viewModel.endCall()
                    }
                } else {
                    HStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .secondary,
                            content: .init(title: viewModel.isMuted ? VoiceClaimStrings.unmute : VoiceClaimStrings.mute)
                        ) {
                            viewModel.toggleMute()
                        }
                        hButton(.large, .alert, content: .init(title: VoiceClaimStrings.endCall)) {
                            viewModel.endCall()
                        }
                    }
                    hButton(.large, .ghost, content: .init(title: VoiceClaimStrings.switchToTyping)) {
                        viewModel.switchToTyping()
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .disabled(viewModel.phase == .finished)
        .padding(.bottom, .padding16)
    }

    // hCoreUI's detent only reports a swipe-down through the binding (`onUserDismiss` is for centered modals). It
    // also reports it when an earlier sheet's controller goes away, which can be after the next sheet opened, so each
    // binding carries the step it was made for and only that step's sheet can be dismissed through it.
    private var uploadPresented: Binding<Bool> {
        let shown = viewModel.uploadStep
        return Binding(
            get: { viewModel.uploadStep != nil },
            set: { if !$0 { viewModel.uploadSheetDismissed(shown) } }
        )
    }

    private var summaryPresented: Binding<Bool> {
        let shown = viewModel.summaryStep
        return Binding(
            get: { viewModel.summaryStep != nil },
            set: { if !$0 { viewModel.summarySheetDismissed(shown) } }
        )
    }
}

/// The engine's own upload step over the orb, opening the picker straight away.
private struct VoiceClaimUploadSheet: View {
    let step: SubmitClaimFileUploadStep
    /// The member picked files: in voice there's no separate "Send" tap, the upload starts right away.
    let onPicked: () -> Void

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: .padding16) {
                if let text = step.getText() {
                    hSection {
                        hText(text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .sectionContainerStyle(.transparent)
                }
                // The chat's step wrapper: disabled while submitting (a second tap would cancel the first
                // submit and drop its result), plus the skip button.
                ClaimStepView(viewModel: step)
                VoiceClaimStepError(step: step)
            }
            .padding(.top, .padding16)
        }
        .hFormContentPosition(.compact)
        .onAppear { step.showFileSourcePicker = true }
        .onChange(of: step.fileUploadVm.hasFiles) { _, hasFiles in
            if hasFiles { onPicked() }
        }
    }
}

/// The engine's own summary over the orb; the member taps "Submit claim" here, never the agent.
private struct VoiceClaimSummarySheet: View {
    let step: SubmitClaimSummaryStep

    var body: some View {
        hForm {
            SubmitClaimSummaryView(viewModel: step)
                .padding(.top, .padding16)
        }
        .hFormAttachToBottom {
            VStack(spacing: .padding8) {
                VoiceClaimStepError(step: step)
                // Renders the summary's submit button, disabled while it's submitting.
                ClaimStepView(viewModel: step)
            }
        }
    }
}

/// A failed submit in a sheet. The chat shows these as alerts from its own screen, which voice doesn't host.
private struct VoiceClaimStepError: View {
    let step: ClaimIntentStepHandler

    var body: some View {
        if let message = step.state.error?.localizedDescription, !message.isEmpty {
            hSection {
                hText(message, style: .label)
                    .foregroundColor(hSignalColor.Red.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
