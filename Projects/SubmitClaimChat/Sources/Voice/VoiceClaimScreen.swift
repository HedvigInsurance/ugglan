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
                    switchToTypingButton(.primary)
                    hButton(.large, .ghost, content: .init(title: L10n.generalCloseButton)) {
                        viewModel.endCall()
                    }
                } else {
                    HStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .secondary,
                            content: .init(
                                title: viewModel.isMuted ? VoiceClaimStrings.unmute : VoiceClaimStrings.mute,
                                // The icon shows the microphone as it is now, the title what a tap does.
                                buttonImage: .init(
                                    image: viewModel.isMuted ? VoiceCallIcon.microphoneOff : VoiceCallIcon.microphone,
                                    alignment: .leading,
                                    size: .large
                                )
                            )
                        ) {
                            viewModel.toggleMute()
                        }
                        hButton(
                            .large,
                            .alert,
                            content: .init(
                                title: VoiceClaimStrings.endCall,
                                buttonImage: .init(image: VoiceCallIcon.hangUp, alignment: .leading, size: .large)
                            )
                        ) {
                            viewModel.endCall()
                        }
                    }
                    switchToTypingButton(.ghost)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .disabled(viewModel.phase == .finished)
        .padding(.bottom, .padding16)
    }

    /// The pen, like the chat's own "Write" button.
    private func switchToTypingButton(_ type: hButtonConfigurationType) -> some View {
        hButton(
            .large,
            type,
            content: .init(
                title: VoiceClaimStrings.switchToTyping,
                buttonImage: .init(image: VoiceCallIcon.typing, alignment: .leading, size: .large)
            )
        ) {
            viewModel.switchToTyping()
        }
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

/// The call buttons' icons, on the design system's 24 pt grid. hCoreUI has a mic and a pen, but no muted mic or
/// handset, so those two are drawn here.
@MainActor
private enum VoiceCallIcon {
    static let microphone = hCoreUIAssets.mic.view
    static let typing = hCoreUIAssets.penEdit.view

    /// hCoreUI's mic, struck through like the system's muted mic.
    static let microphoneOff = icon { _ in
        hCoreUIAssets.mic.image.withTintColor(.black, renderingMode: .alwaysOriginal).draw(in: grid)
        let slash = UIBezierPath()
        slash.move(to: CGPoint(x: 4, y: 4))
        slash.addLine(to: CGPoint(x: 20, y: 20))
        slash.lineCapStyle = .round
        // A gap either side of the slash, then the slash itself in the icon set's 1.5 pt line.
        slash.lineWidth = 4.5
        slash.stroke(with: .clear, alpha: 1)
        slash.lineWidth = 1.5
        UIColor.black.setStroke()
        slash.stroke()
    }

    /// The system's hang-up handset, centred on the square grid: hButton draws its icon resizable in a square frame,
    /// which would stretch the wide handset. Bold and nearly the grid's width, or it looks lighter than the mic.
    static let hangUp = icon { _ in
        let bold = UIImage.SymbolConfiguration(weight: .bold)
        guard let handset = UIImage(systemName: "phone.down.fill", withConfiguration: bold) else { return }
        let width: CGFloat = 22
        let height = width * handset.size.height / handset.size.width
        handset.withTintColor(.black, renderingMode: .alwaysOriginal)
            .draw(in: CGRect(x: (grid.width - width) / 2, y: (grid.height - height) / 2, width: width, height: height))
    }

    private static let grid = CGRect(x: 0, y: 0, width: 24, height: 24)

    /// Only the shape counts: the button tints it like its title.
    private static func icon(_ draw: (UIGraphicsImageRendererContext) -> Void) -> Image {
        Image(uiImage: UIGraphicsImageRenderer(bounds: grid).image(actions: draw).withRenderingMode(.alwaysTemplate))
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
