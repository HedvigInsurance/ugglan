import AVFoundation
import SwiftUI
import hCore
import hCoreUI

// MARK: - Main Voice Recording View
struct SubmitClaimVoiceRecordingView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @StateObject private var voiceRecorder = VoiceRecorder()
    @State private var showError = false

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                if viewModel.isTextInputPresented {
                    textInputSection
                } else {
                    initialButtons
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .onChange(of: voiceRecorder.error) { error in
            showError = error != nil
        }
        .detent(presented: $viewModel.isAudioInputPresented) {
            VoiceRecordingCardContent(
                voiceRecorder: voiceRecorder,
                onSend: {
                    viewModel.audioFileURL = voiceRecorder.recordedFileURL
                    viewModel.submitResponse()
                },
                onStartOver: {
                    voiceRecorder.startOver()
                },
                onUseText: {
                    voiceRecorder.reset()
                    withAnimation {
                        viewModel.isAudioInputPresented = false
                        viewModel.isTextInputPresented = true
                    }
                }
            )
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text(L10n.generalError),
                message: Text(voiceRecorder.error?.localizedDescription ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
        .animation(.default, value: viewModel.isTextInputPresented)
    }

    // MARK: - Initial Buttons
    private var initialButtons: some View {
        VStack(spacing: .padding8) {
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.claimChatUseAudio)
            ) {
                viewModel.isAudioInputPresented = true
            }

            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.claimChatUseTextInput)
            ) {
                withAnimation {
                    viewModel.isTextInputPresented = true
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Text Input Section
    private var textInputSection: some View {
        VStack(spacing: .padding16) {
            hTextView(
                selectedValue: viewModel.textInput,
                placeholder: L10n.claimsTextInputPlaceholder,
                popupPlaceholder: L10n.claimsTextInputPopoverPlaceholder,
                minCharacters: viewModel.audioRecordingModel.freeTextMinLength,
                maxCharacters: viewModel.audioRecordingModel.freeTextMaxLength
            ) { text in
                viewModel.textInput = text
            }
            .hTextFieldError(viewModel.textInputError)

            VStack(spacing: .padding8) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.saveAndContinueButtonLabel)
                ) {
                    UIApplication.dismissKeyboard()
                    viewModel.submitResponse()
                }
                .disabled(viewModel.characterMismatch)

                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.claimsUseAudioRecording)
                ) {
                    withAnimation {
                        viewModel.isTextInputPresented = false
                        viewModel.isAudioInputPresented = true
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Voice Recording Card Content
struct VoiceRecordingCardContent: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () -> Void
    let onStartOver: () -> Void
    let onUseText: () -> Void

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                // Title
                hText(L10n.claimsTriagingWhatHappenedTitle, style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)

                // Waveform area
                waveformSection
                    .frame(height: 60)

                // Timer (when recording or recorded)
                if voiceRecorder.isRecording || voiceRecorder.hasRecording {
                    hText(voiceRecorder.formattedTime, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }

                // Bottom controls
                controlsSection
            }
            .padding(.padding16)
        }
        .hFormContentPosition(.compact)
    }

    @ViewBuilder
    private var waveformSection: some View {
        if voiceRecorder.isRecording {
            VoiceWaveformView(
                audioLevels: voiceRecorder.audioLevels,
                isRecording: true,
                maxHeight: 60
            )
        } else if voiceRecorder.hasRecording {
            VoiceWaveformView(
                audioLevels: voiceRecorder.audioLevels,
                isRecording: false,
                maxHeight: 60
            )
        } else {
            IdleWaveformView()
        }
    }

    private var controlsSection: some View {
        HStack(spacing: .padding16) {
            // Start over button (left)
            if voiceRecorder.hasRecording {
                Button(action: onStartOver) {
                    hText(L10n.embarkRecordAgain, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Button(action: onUseText) {
                    hText(L10n.claimsUseTextInstead, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Record button (center)
            VoiceRecordButton(isRecording: voiceRecorder.isRecording) {
                Task {
                    await voiceRecorder.toggleRecording()
                }
            }

            // Send button (right)
            Button(action: onSend) {
                hText(L10n.chatUploadPresend, style: .body1)
                    .foregroundColor(uploadTextColor)
                    .padding(.horizontal, .padding16)
                    .padding(.vertical, .padding8)
                    .background(
                        Capsule()
                            .fill(uploadCapsuleColor)
                    )
            }
            .disabled(!voiceRecorder.hasRecording)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @hColorBuilder
    private var uploadTextColor: some hColor {
        if voiceRecorder.hasRecording {
            hTextColor.Opaque.negative
        } else {
            hTextColor.Opaque.tertiary
        }
    }

    @hColorBuilder
    private var uploadCapsuleColor: some hColor {
        if voiceRecorder.hasRecording {
            hSignalColor.Blue.element
        } else {
            hFillColor.Opaque.disabled
        }
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
    }

    private var textResultView: some View {
        HStack {
            hText(viewModel.textInput)
                .frame(alignment: .topLeading)
            Spacer()
        }
        .hPillStyle(color: .grey, colorLevel: .two)
        .hFieldSize(.extraLarge)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.textInput)
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
