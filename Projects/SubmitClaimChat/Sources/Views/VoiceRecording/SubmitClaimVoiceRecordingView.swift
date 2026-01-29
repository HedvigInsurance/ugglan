import AVFoundation
import SwiftUI
import hCore
import hCoreUI

// MARK: - Main Voice Recording View
struct SubmitClaimVoiceRecordingView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @ObservedObject var voiceRecorder: VoiceRecorder

    init(viewModel: SubmitClaimAudioStep) {
        self.viewModel = viewModel
        self.voiceRecorder = viewModel.voiceRecorder
    }

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
        .detent(presented: $viewModel.isAudioInputPresented) {
            VoiceRecordingCardContent(
                voiceRecorder: voiceRecorder,
                onSend: { [weak viewModel, weak voiceRecorder] in
                    viewModel?.audioFileURL = voiceRecorder?.recordedFileURL
                    try await viewModel?.uploadAudioRecording()
                    viewModel?.submitResponse()
                }
            )
            .disabled(!viewModel.state.isEnabled)
            .embededInNavigation(
                options: [.navigationBarHidden],
                tracking: SubmitClaimVoiceRecordingViewDetentType.voiceRecording
            )
        }
        .onChange(of: viewModel.isAudioInputPresented) { isPresented in
            if !isPresented {
                voiceRecorder.stopRecording()
                voiceRecorder.stopPlayback()
            }
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

    enum SubmitClaimVoiceRecordingViewDetentType: TrackingViewNameProtocol, NavigationTitleProtocol {
        case voiceRecording

        var nameForTracking: String {
            String(describing: VoiceRecordingCardContent.self)
        }

        var navigationTitle: String? {
            L10n.claimsTriagingWhatHappenedTitle
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
                    .padding(.leading, .padding48)
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
