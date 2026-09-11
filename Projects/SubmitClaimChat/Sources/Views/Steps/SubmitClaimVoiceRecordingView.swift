import AVFoundation
import SwiftUI
import hCore
import hCoreUI

// MARK: - Main Voice Recording View
//
// Redesigned description input (Figma "Claim input chat"): Skriv · Spela in side by side,
// then an inline card for text or voice instead of the stacked buttons + voice detent.
struct SubmitClaimVoiceRecordingView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @ObservedObject var voiceRecorder: VoiceRecorder

    init(viewModel: SubmitClaimAudioStep) {
        self.viewModel = viewModel
        self.voiceRecorder = viewModel.voiceRecorder
    }

    var body: some View {
        hSection {
            if viewModel.isTextInputPresented {
                textInputCard
            } else if viewModel.isAudioInputPresented {
                voiceInputCard
            } else {
                initialButtons
            }
        }
        .sectionContainerStyle(.transparent)
        .onChange(of: viewModel.isAudioInputPresented) { isPresented in
            if !isPresented {
                voiceRecorder.stopRecording()
                voiceRecorder.stopPlayback()
            }
        }
        .animation(.default, value: viewModel.isTextInputPresented)
        .animation(.default, value: viewModel.isAudioInputPresented)
    }

    // MARK: - Initial Buttons (Skriv · Spela in)
    private var initialButtons: some View {
        HStack(spacing: .padding8) {
            hButton(
                .large,
                .secondary,
                content: .init(
                    title: SubmitClaimAudioStepCopy.write,
                    buttonImage: .init(image: hCoreUIAssets.edit.view, alignment: .leading)
                )
            ) {
                viewModel.isTextInputPresented = true
            }
            hButton(
                .large,
                .secondary,
                content: .init(
                    title: SubmitClaimAudioStepCopy.record,
                    buttonImage: .init(image: hCoreUIAssets.mic.view, alignment: .leading)
                )
            ) {
                voiceRecorder.startOver()
                viewModel.isAudioInputPresented = true
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Text card
    private var textInputCard: some View {
        SubmitClaimTextInputCard(viewModel: viewModel)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Voice card (same recorder and tiles as the previous detent, now inline)
    private var voiceInputCard: some View {
        VoiceRecordingInlineCard(
            voiceRecorder: voiceRecorder,
            onSend: { [weak viewModel, weak voiceRecorder] in
                viewModel?.audioFileURL = voiceRecorder?.recordedFileURL
                try await viewModel?.uploadAudioRecording()
                viewModel?.submitResponse()
            },
            onClose: { [weak viewModel] in
                viewModel?.isAudioInputPresented = false
            }
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

/// Copy without Lokalise keys yet – see Figma "Claim input chat" copy table.
enum SubmitClaimAudioStepCopy {
    // TODO: Lokalise keys for the redesigned description step.
    static let write = "Skriv"
    static let record = "Spela in"
    static let textFieldLabel = "Beskriv vad som hänt"
}

// MARK: - Text card: label · multiline field · Avbryt / Skicka
struct SubmitClaimTextInputCard: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @FocusState private var isFocused: Bool

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
                if let error = viewModel.textInputError, !viewModel.textInput.isEmpty {
                    hText(error, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: .padding8) {
                Spacer(minLength: 0)
                hButton(.medium, .secondary, content: .init(title: L10n.generalCancelButton)) {
                    UIApplication.dismissKeyboard()
                    viewModel.isTextInputPresented = false
                }
                hButton(.medium, .primary, content: .init(title: L10n.chatUploadPresend)) {
                    UIApplication.dismissKeyboard()
                    viewModel.submitResponse()
                }
                .disabled(viewModel.characterMismatch)
                .hButtonIsLoading(viewModel.state.isLoading)
            }
        }
        .padding(.padding16)
        .modifier(SubmitClaimInputCardBackground())
        .onAppear {
            guard viewModel.showTextViewOnAppear else { return }
            Task {
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.layoutUpdate)
                isFocused = true
            }
        }
        .onChange(of: viewModel.state.isEnabled) { isEnabled in
            if !isEnabled { isFocused = false }
        }
    }
}

/// Card container shared by the text and voice inputs (Figma "Menu - iPhone").
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
#Preview("Initial State") {
    let viewModel = SubmitClaimAudioStep(
        claimIntent: .init(
            currentStep: .init(
                content: .audioRecording(
                    model: .init(
                        uploadURI: "/upload",
                        freeTextMinLength: 10,
                        freeTextMaxLength: 500
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
    return VStack {
        Spacer()
        SubmitClaimVoiceRecordingView(viewModel: viewModel)
            .padding()
    }
}

#Preview("Voice Recording") {
    let viewModel = SubmitClaimAudioStep(
        claimIntent: .init(
            currentStep: .init(
                content: .audioRecording(
                    model: .init(
                        uploadURI: "/upload",
                        freeTextMinLength: 10,
                        freeTextMaxLength: 500
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
    return VStack {
        Spacer()
        SubmitClaimVoiceRecordingView(viewModel: viewModel)
            .padding()
    }
}

#Preview("Text Input") {
    let viewModel = SubmitClaimAudioStep(
        claimIntent: .init(
            currentStep: .init(
                content: .audioRecording(
                    model: .init(
                        uploadURI: "/upload",
                        freeTextMinLength: 10,
                        freeTextMaxLength: 500
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
    viewModel.isTextInputPresented = true
    return VStack {
        Spacer()
        SubmitClaimVoiceRecordingView(viewModel: viewModel)
            .padding()
    }
}
