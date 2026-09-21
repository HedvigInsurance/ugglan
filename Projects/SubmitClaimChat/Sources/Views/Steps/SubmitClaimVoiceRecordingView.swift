import AVFoundation
import SwiftUI
import hCore
import hCoreUI

// MARK: - Main Voice Recording View
struct SubmitClaimVoiceRecordingView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep

    var body: some View {
        hSection {
            if viewModel.isSkippable && !viewModel.state.disableSkip {
                HStack(spacing: .padding8) {
                    textInputButton
                    audioInputButton
                }
            } else {
                VStack(spacing: .padding8) {
                    textInputButton
                    audioInputButton
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .transition(.opacity)
    }

    private var textInputButton: some View {
        hButton(
            .large,
            .secondary,
            content: .init(
                title: L10n.claimsWrite,
                buttonImage: .init(image: hCoreUIAssets.penEdit.view, alignment: .leading, size: .large)
            )
        ) {
            viewModel.beginText()
        }
    }

    private var audioInputButton: some View {
        hButton(
            .large,
            .secondary,
            content: .init(
                title: L10n.claimsRecord,
                buttonImage: .init(image: hCoreUIAssets.mic.view, alignment: .leading, size: .large)
            )
        ) {
            viewModel.beginVoice()
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
            if viewModel.submittedKind == .text {
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
extension SubmitClaimAudioStep {
    @MainActor
    static func preview(textInput: String? = nil, isSkippable: Bool = true) -> SubmitClaimAudioStep {
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
                isSkippable: isSkippable,
                isRegrettable: false,
                progress: 0.3
            ),
            service: .init(),
            mainHandler: { _ in }
        )
    }
}

#Preview("Skippable · side by side") {
    VStack {
        Spacer()
        ClaimStepView(viewModel: SubmitClaimAudioStep.preview())
            .padding()
    }
}

#Preview("Not skippable · stacked") {
    VStack {
        Spacer()
        ClaimStepView(viewModel: SubmitClaimAudioStep.preview(isSkippable: false))
            .padding()
    }
}

#Preview("Voice card") {
    let viewModel = SubmitClaimAudioStep.preview()
    viewModel.beginVoice()
    return VStack {
        Spacer()
        ClaimInputCardView(viewModel: viewModel)
            .padding()
    }
}
