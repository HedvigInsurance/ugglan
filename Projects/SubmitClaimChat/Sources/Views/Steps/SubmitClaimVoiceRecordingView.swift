import AVFoundation
import SwiftUI
import hCore
import hCoreUI

// MARK: - Main Voice Recording View
//
// Description step input (Figma "App P2 2026", section "5 · Text / voice input"): Skriv · Spela in side by side, then an
// inline card for text or voice in the same docked area, instead of the stacked buttons + voice detent.
struct SubmitClaimVoiceRecordingView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @ObservedObject var voiceRecorder: VoiceRecorder

    init(viewModel: SubmitClaimAudioStep) {
        self.viewModel = viewModel
        self.voiceRecorder = viewModel.voiceRecorder
    }

    var body: some View {
        hSection {
            // Row and card overlap during the crossfade so the card slides in over the row.
            ZStack(alignment: .bottom) {
                if viewModel.isTextInputPresented {
                    textInputCard
                } else if viewModel.isAudioInputPresented {
                    voiceInputCard
                } else {
                    initialButtons
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .animation(.defaultSpring, value: viewModel.isTextInputPresented)
        .animation(.defaultSpring, value: viewModel.isAudioInputPresented)
    }

    // MARK: - Initial Buttons (Skriv · Spela in)
    // Secondary resting token, made opaque over the blurred panel (page background behind the capsule).
    private var initialButtons: some View {
        HStack(spacing: .padding8) {
            hButton(
                .large,
                .secondary,
                content: .init(
                    title: SubmitClaimAudioStepCopy.write,
                    buttonImage: .init(image: hCoreUIAssets.penEdit.view, alignment: .leading)
                )
            ) {
                viewModel.presentTextInput()
            }
            .background(Capsule().fill(hBackgroundColor.primary))
            hButton(
                .large,
                .secondary,
                content: .init(
                    title: SubmitClaimAudioStepCopy.record,
                    buttonImage: .init(image: hCoreUIAssets.mic.view, alignment: .leading)
                )
            ) {
                viewModel.presentAudioInput()
            }
            .background(Capsule().fill(hBackgroundColor.primary))
        }
        .geometryGroupIfAvailable()
        .transition(.opacity)
    }

    // MARK: - Text card
    private var textInputCard: some View {
        SubmitClaimTextInputCard(viewModel: viewModel)
            .geometryGroupIfAvailable()
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Voice card (same recorder and tiles as the previous detent, now inline)
    private var voiceInputCard: some View {
        VoiceRecordingInlineCard(
            voiceRecorder: voiceRecorder,
            onSend: {
                viewModel.audioFileURL = voiceRecorder.recordedFileURL
                try await viewModel.uploadAudioRecording()
                viewModel.submitResponse()
            },
            onClose: {
                viewModel.dismissInput()
            }
        )
        .geometryGroupIfAvailable()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

/// Copy without Lokalise keys yet – see Figma "App P2 2026", section "5 · Text / voice input", section 5 (Copy).
enum SubmitClaimAudioStepCopy {
    // TODO: Lokalise keys for the redesigned description step.
    static let write = "Skriv"
    static let record = "Spela in"
    static let textFieldLabel = "Beskriv vad som hänt"
    static let sending = "Skickar…"
}

// MARK: - Text card: label · multiline field · Avbryt / Skicka (Figma section 2)
struct SubmitClaimTextInputCard: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @EnvironmentObject var scrollCoordinator: ClaimChatScrollCoordinator
    @FocusState private var isFocused: Bool
    /// The min/max-length message would make the card jump on every keystroke, so it is only shown
    /// after the user taps the disabled Skicka button, and goes away once the text is valid.
    @State private var showsValidationError = false

    var body: some View {
        VStack(spacing: .padding16) {
            VStack(alignment: .leading, spacing: .padding4) {
                hText(SubmitClaimAudioStepCopy.textFieldLabel, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                TextField(L10n.chatInputPlaceholder, text: $viewModel.textInput, axis: .vertical)
                    .font(Font(Fonts.fontFor(style: .body1)))
                    .foregroundColor(
                        viewModel.state.isEnabled ? hTextColor.Opaque.primary : hTextColor.Opaque.secondary
                    )
                    .lineLimit(1...6)
                    .focused($isFocused)
                    .disabled(!viewModel.state.isEnabled)
                    .accessibilityLabel(SubmitClaimAudioStepCopy.textFieldLabel)
                if showsValidationError, let error = viewModel.textInputError {
                    hText(error, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: .padding8) {
                Spacer(minLength: 0)
                hButton(.medium, .secondary, content: .init(title: L10n.generalCancelButton)) {
                    viewModel.dismissInput()
                }
                .disabled(viewModel.state.isLoading)
                hButton(.medium, .primary, content: .init(title: L10n.chatUploadPresend)) {
                    viewModel.submitResponse()
                }
                .disabled(viewModel.characterMismatch)
                .hButtonIsLoading(viewModel.state.isLoading)
                .overlay {
                    // A disabled button ignores taps; catch them here to explain why it is disabled.
                    if viewModel.characterMismatch {
                        Button {
                            withAnimation(.defaultSpring) { showsValidationError = true }
                        } label: {
                            Color.clear.contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(.padding16)
        .modifier(SubmitClaimInputCardBackground())
        .onChange(of: viewModel.textInput) { _ in
            if !viewModel.characterMismatch {
                withAnimation(.defaultSpring) { showsValidationError = false }
            }
        }
        .onAppear {
            // The chat dismisses the keyboard on scroll; keep it while this card is open.
            scrollCoordinator.keepsKeyboardWhileScrolling = true
            guard viewModel.showTextViewOnAppear else { return }
            Task {
                // Focus after the card has landed so the keyboard reliably opens with it.
                await delay(ClaimChatConstants.Timing.layoutUpdate)
                isFocused = true
            }
        }
        .onDisappear {
            scrollCoordinator.keepsKeyboardWhileScrolling = false
        }
        .onChange(of: viewModel.state.isLoading) { isLoading in
            // Figma 2.3: the keyboard goes down while sending.
            if isLoading { isFocused = false }
        }
        .onChange(of: viewModel.state.isEnabled) { isEnabled in
            if !isEnabled { isFocused = false }
        }
    }
}

/// Card container shared by the text and voice inputs (Figma "Menu - iPhone": radius 32, soft shadow).
struct SubmitClaimInputCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusXXL + .padding8)
                    .fill(hFillColor.Opaque.negative)
            )
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
    }
}

// MARK: - Result View (shown after submission)
struct SubmitClaimVoiceRecordingResultView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @StateObject private var audioPlayer: AudioPlayer

    init(viewModel: SubmitClaimAudioStep) {
        self.viewModel = viewModel
        self._audioPlayer = StateObject(wrappedValue: AudioPlayer(url: viewModel.audioFileURL))
    }

    var body: some View {
        VStack {
            if viewModel.isTextInputPresented {
                textResultView
            } else if let url = viewModel.audioFileURL {
                audioResultView(url: url)
            }
        }
        .padding(.leading, .padding48)
    }

    private var textResultView: some View {
        let displayText = viewModel.textInput.isEmpty ? L10n.claimChatSkippedStep : viewModel.textInput
        return hText(displayText)
            .foregroundColor(viewModel.textInput.isEmpty ? hTextColor.Translucent.secondary : hTextColor.Opaque.primary)
            .hPillStyle(color: .grey, colorLevel: .two)
            .hFieldSize(.extraLarge)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(displayText)
    }

    private func audioResultView(url: URL) -> some View {
        TrackPlayerView(audioPlayer: audioPlayer)
            .trackPlayerBackground {
                Color.clear
                    .hPillStyle(color: .grey, colorLevel: .two)
            }
            .hFieldSize(.extraLarge)
            .onAppear {
                audioPlayer.url = url
            }
    }
}

// MARK: - Preview
@MainActor
private func previewStep(textInput: String? = nil) -> SubmitClaimAudioStep {
    SubmitClaimAudioStep(
        claimIntent: .init(
            currentStep: .init(
                content: .audioRecording(
                    model: .init(
                        uploadURI: "/upload",
                        freeTextMinLength: 10,
                        freeTextMaxLength: 500,
                        currentFreeText: textInput
                    )
                ),
                id: "step1",
                text: "Tell us what happened"
            ),
            id: "intent1",
            isSkippable: false,
            isRegrettable: false,
            progress: 0.3
        ),
        service: .init(),
        mainHandler: { _ in }
    )
}

#Preview("Initial State") {
    VStack {
        Spacer()
        SubmitClaimVoiceRecordingView(viewModel: previewStep())
            .padding()
    }
    .environmentObject(ClaimChatScrollCoordinator())
}

#Preview("Voice card") {
    let viewModel = previewStep()
    viewModel.isAudioInputPresented = true
    return VStack {
        Spacer()
        SubmitClaimVoiceRecordingView(viewModel: viewModel)
            .padding()
    }
    .environmentObject(ClaimChatScrollCoordinator())
}

#Preview("Text card") {
    VStack {
        Spacer()
        SubmitClaimVoiceRecordingView(viewModel: previewStep(textInput: "Lorem ipsum dolor sit amet"))
            .padding()
    }
    .environmentObject(ClaimChatScrollCoordinator())
}
