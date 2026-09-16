import AVFoundation
import SwiftUI
import hCore
import hCoreUI

// MARK: - Main Voice Recording View
//
// Description step input (Figma "App P2 2026", section "5 · Text / voice input"): Skriv · Spela in. Tapping either
// opens a card that replaces the whole docked input area – see `ClaimInputCardView`.
struct SubmitClaimVoiceRecordingView: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep

    var body: some View {
        hSection {
            // Side by side only when the skip button is there to absorb the height; stacked otherwise, so two large
            // buttons plus a third row still fit on small devices.
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
                title: SubmitClaimAudioStepCopy.write,
                buttonImage: .init(image: hCoreUIAssets.penEdit.view, alignment: .leading)
            )
        ) { [weak viewModel] in
            viewModel?.beginText()
        }
    }

    private var audioInputButton: some View {
        hButton(
            .large,
            .secondary,
            content: .init(
                title: SubmitClaimAudioStepCopy.record,
                buttonImage: .init(image: hCoreUIAssets.mic.view, alignment: .leading)
            )
        ) { [weak viewModel] in
            viewModel?.beginVoice()
        }
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
