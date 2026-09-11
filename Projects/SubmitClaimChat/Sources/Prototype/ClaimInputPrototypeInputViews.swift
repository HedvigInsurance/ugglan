import SwiftUI
import TagKit
import hCore
import hCoreUI

private typealias Copy = ClaimInputPrototypeCopy

// MARK: - 1.x Resting: Skriv · Spela in · Hoppa över (docked, mirrors ClaimStepView)
struct ClaimInputPrototypeChoiceView: View {
    @EnvironmentObject var viewModel: ClaimInputPrototypeViewModel

    var body: some View {
        hSection {
            VStack(spacing: .padding4) {
                HStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .secondary,
                        content: .init(
                            title: Copy.write,
                            buttonImage: .init(image: hCoreUIAssets.edit.view, alignment: .leading)
                        )
                    ) {
                        viewModel.beginText()
                    }
                    hButton(
                        .large,
                        .secondary,
                        content: .init(
                            title: Copy.record,
                            buttonImage: .init(image: hCoreUIAssets.mic.view, alignment: .leading)
                        )
                    ) {
                        viewModel.beginVoice()
                    }
                }
                hButton(.large, .ghost, content: .init(title: L10n.claimChatSkipStep)) {
                    viewModel.skip()
                }
                .accessibilityHint(L10n.generalContinueButton)
            }
        }
        .sectionContainerStyle(.transparent)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Follow-up steps: single select pills + confirm (mirrors SubmitClaimSingleSelectView, .pill style)
struct ClaimInputPrototypeSelectView: View {
    @EnvironmentObject var viewModel: ClaimInputPrototypeViewModel
    @ObservedObject var step: ClaimInputPrototypeStep
    @State private var showOptions = false

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: .padding16) {
                TagList(tags: step.options) { option in
                    if showOptions {
                        hPill(
                            text: option,
                            color: step.selectedOption == option ? .green : .grey,
                            colorLevel: .two,
                            withBorder: false,
                            minWidth: .padding60
                        )
                        .hFieldSize(.large)
                        .capsuleShape(true)
                        .transition(.prototypeOptionAppear)
                        .onTapGesture {
                            ImpactGenerator.soft()
                            step.selectedOption = option
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel(option)
                    }
                }
                .tagFlow(
                    .horizontal(
                        .init(
                            horizontalAlignment: .leading,
                            verticalAlignment: .center,
                            horizontalSpacing: .padding8,
                            verticalSpacing: .padding8
                        )
                    )
                )
                hButton(.large, .primary, content: .init(title: L10n.generalConfirm)) {
                    viewModel.confirmSelection()
                }
                .opacity(showOptions ? 1 : 0)
                .animation(.easeInOut, value: showOptions)
                .disabled(step.selectedOption == nil)
            }
        }
        .sectionContainerStyle(.transparent)
        .animation(.easeInOut, value: step.selectedOption)
        .task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.optionReveal)
            showOptions = true
        }
    }
}

extension AnyTransition {
    fileprivate static var prototypeOptionAppear: AnyTransition {
        .scale.animation(
            .spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1)
                .delay(Double.random(in: 0.3...0.6))
        )
    }
}

// MARK: - 2.x Text card above the keyboard
struct ClaimInputPrototypeTextCard: View {
    @EnvironmentObject var viewModel: ClaimInputPrototypeViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: .padding16) {
            VStack(alignment: .leading, spacing: .padding4) {
                hText(Copy.textFieldLabel, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                TextField(L10n.chatInputPlaceholder, text: $viewModel.draftText, axis: .vertical)
                    .font(Font(Fonts.fontFor(style: .body1)))
                    .foregroundColor(viewModel.isSaving ? hTextColor.Opaque.secondary : hTextColor.Opaque.primary)
                    .lineLimit(1...6)
                    .focused($isFocused)
                    .disabled(viewModel.isSaving)
                    .accessibilityLabel(Copy.textFieldLabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: .padding8) {
                Spacer(minLength: 0)
                hButton(.medium, .secondary, content: .init(title: L10n.generalCancelButton)) {
                    viewModel.cancelInput()
                }
                .disabled(viewModel.isSaving)
                hButton(.medium, .primary, content: .init(title: L10n.chatUploadPresend)) {
                    viewModel.saveText()
                }
                .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .hButtonIsLoading(viewModel.isSaving)
            }
        }
        .padding(.padding16)
        .modifier(ClaimInputPrototypeCardBackground())
        .onAppear {
            // Focus after the card has landed so the keyboard reliably opens with it.
            Task {
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.layoutUpdate)
                isFocused = true
            }
        }
        .onChange(of: viewModel.isSaving) { isSaving in
            // Figma 2.5: keyboard goes down while saving.
            if isSaving { isFocused = false }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - 3.x Voice card – same recorder and control tiles as VoiceRecordingCardContent
struct ClaimInputPrototypeVoiceCard: View {
    @EnvironmentObject var viewModel: ClaimInputPrototypeViewModel
    @ObservedObject var voiceRecorder: VoiceRecorder
    @State private var waveformWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                hText(Copy.voiceTitle)
                    .foregroundColor(titleColor)
                    .accessibilityHidden(voiceRecorder.isCountingDown || voiceRecorder.isRecording)
                hText(voiceRecorder.isSending ? Copy.sending : (voiceRecorder.formattedTime ?? " "), style: .body1)
                    .foregroundColor(timerColor)
                    .accessibilityHidden(!voiceRecorder.isSending)
            }
            .padding(.top, .padding8)
            .opacity(voiceRecorder.error != nil ? 0 : 1)

            ZStack {
                if let error = voiceRecorder.error {
                    VStack(spacing: .padding4) {
                        hText(error.title ?? L10n.somethingWentWrong)
                        hText(error.errorDescription ?? "", style: .label)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                }
                // Figma 3.6: while sending the waveform stays, greyed out, and every tile is disabled.
                waveformSection
                    .padding(.horizontal, .padding8)
                    .padding(.vertical, .padding64)
                    .opacity(voiceRecorder.error != nil ? 0 : (voiceRecorder.isSending ? 0.35 : 1))
                    .animation(.easeInOut(duration: 0.2), value: voiceRecorder.isSending)
                    .animation(.defaultSpring, value: voiceRecorder.hasRecording)
                    .accessibilityHidden(
                        voiceRecorder.isCountingDown || voiceRecorder.isRecording || !voiceRecorder.hasRecording
                    )
            }

            HStack(spacing: .padding4) {
                VoiceStartOverButton()
                if !voiceRecorder.hasRecording {
                    VoiceRecordButton()
                } else {
                    VoicePlaybackButton()
                }
                ClaimInputPrototypeSendTile(onTap: { [weak viewModel] in
                    try await viewModel?.sendVoice()
                })
            }
            // The tiles use Spacers internally (wrapContentForControlButton); keep them hugging like in the detent.
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.padding16)
        .overlay(alignment: .topTrailing) {
            if !voiceRecorder.isSending {
                Button {
                    viewModel.cancelInput()
                } label: {
                    hCoreUIAssets.close.view
                        .foregroundColor(hFillColor.Opaque.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .padding(.padding6)
                .accessibilityLabel(L10n.a11YClose)
            }
        }
        .modifier(ClaimInputPrototypeCardBackground())
        .disabled(voiceRecorder.isSending)
        .environmentObject(voiceRecorder)
        .animation(.easeInOut(duration: 0.2), value: voiceRecorder.error)
        .animation(.easeInOut(duration: 0.2), value: voiceRecorder.isSending)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    /// Figma 3.6: the title stays in ink while sending; only the subtitle and tiles are greyed.
    private var titleColor: some hColor {
        hTextColor.Opaque.primary
    }

    @hColorBuilder
    private var timerColor: some hColor {
        if !voiceRecorder.isSending {
            hTextColor.Opaque.secondary
        } else {
            hTextColor.Opaque.disabled
        }
    }

    private var isPlaybackMode: Bool {
        voiceRecorder.hasRecording && !voiceRecorder.isRecording
    }

    private var waveformSection: some View {
        VoiceWaveformView(
            audioLevels: Binding(get: { voiceRecorder.audioLevels }, set: { _ in }),
            isRecording: Binding(get: { voiceRecorder.isRecording }, set: { _ in }),
            progress: isPlaybackMode ? voiceRecorder.progress : nil
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { waveformWidth = geo.size.width }
                    .onChange(of: geo.size) { size in waveformWidth = size.width }
            }
        )
        .onTapGesture { location in
            guard isPlaybackMode, waveformWidth > 0 else { return }
            voiceRecorder.setProgress(to: min(max(location.x / waveformWidth, 0), 1))
            if !voiceRecorder.isPlaying {
                voiceRecorder.startPlayback()
            }
        }
    }
}

// MARK: - Skicka tile – VoiceSendButton plus the "Skickar…" sending label from Figma 3.6
struct ClaimInputPrototypeSendTile: View {
    let onTap: () async throws -> Void
    @EnvironmentObject var voiceRecorder: VoiceRecorder

    private var isEnabled: Bool { voiceRecorder.hasRecording && !voiceRecorder.isSending }

    var body: some View {
        Button {
            ImpactGenerator.soft()
            Task {
                voiceRecorder.error = nil
                voiceRecorder.isSending = true
                voiceRecorder.stopPlayback()
                do {
                    try await onTap()
                } catch {
                    voiceRecorder.isSending = false
                    voiceRecorder.error = .sendingFailed
                }
            }
        } label: {
            VStack(spacing: .padding4) {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 32, height: 32)
                    hCoreUIAssets.arrowUp.view
                        .foregroundColor(iconColor)
                }
                .opacity(voiceRecorder.isSending ? 0.4 : 1)

                hText(voiceRecorder.isSending ? Copy.sending : L10n.chatUploadPresend, style: .label)
                    .foregroundColor(textColor)
            }
            .wrapContentForControlButton()
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(L10n.chatUploadPresend)
        .accessibilityAddTraits(.isButton)
        .animation(.defaultSpring, value: voiceRecorder.hasRecording)
        .animation(.defaultSpring, value: voiceRecorder.isSending)
    }

    @hColorBuilder
    private var circleColor: some hColor {
        if voiceRecorder.hasRecording {
            hSignalColor.Blue.element
        } else {
            hSurfaceColor.Translucent.secondary
        }
    }

    @hColorBuilder
    private var iconColor: some hColor {
        if voiceRecorder.hasRecording {
            hFillColor.Opaque.white
        } else {
            hFillColor.Opaque.tertiary
        }
    }

    @hColorBuilder
    private var textColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.tertiary
        }
    }
}

// MARK: - 4.2 Voice Memo bubble in the chat after save
struct ClaimInputPrototypeVoiceMemoBubble: View {
    let levels: [CGFloat]
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var playbackTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: .padding16) {
            Button {
                togglePlayback()
            } label: {
                ZStack {
                    Circle()
                        .fill(hSurfaceColor.Translucent.secondary)
                        .frame(width: 32, height: 32)
                    (isPlaying ? hCoreUIAssets.pause.view : hCoreUIAssets.play.view)
                        .foregroundColor(hFillColor.Opaque.primary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPlaying ? L10n.a11YPause : L10n.a11YPlay)

            VoiceWaveformView(
                audioLevels: .constant(levels),
                isRecording: .constant(false),
                maxHeight: 32,
                progress: progress
            )
        }
        .padding(.horizontal, .padding16)
        .frame(height: 64)
        .background(
            Color.clear
                .hPillStyle(color: .grey, colorLevel: .two)
        )
        .hFieldSize(.extraLarge)
        .accessibilityElement(children: .combine)
        .onDisappear {
            playbackTask?.cancel()
        }
    }

    /// Fake playback: the progress mask sweeps across the waveform, nothing is played.
    private func togglePlayback() {
        ImpactGenerator.soft()
        if isPlaying {
            playbackTask?.cancel()
            isPlaying = false
            return
        }
        isPlaying = true
        if progress >= 1 { progress = 0 }
        playbackTask = Task {
            while !Task.isCancelled, progress < 1 {
                try? await Task.sleep(seconds: 0.1)
                withAnimation(.linear(duration: 0.1)) {
                    progress = min(progress + 0.02, 1)
                }
            }
            if !Task.isCancelled {
                isPlaying = false
            }
        }
    }
}

// MARK: - Card container (Figma "Menu - iPhone": white, radius 32, soft shadow)
private struct ClaimInputPrototypeCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(hFillColor.Opaque.negative)
            )
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
    }
}

#Preview("Choice") {
    let viewModel = ClaimInputPrototypeViewModel()
    return VStack {
        Spacer()
        ClaimInputPrototypeChoiceView()
    }
    .environmentObject(viewModel)
}

#Preview("Voice card") {
    let viewModel = ClaimInputPrototypeViewModel()
    return VStack {
        Spacer()
        ClaimInputPrototypeVoiceCard(voiceRecorder: viewModel.voiceRecorder)
            .padding(.horizontal, .padding16)
    }
    .environmentObject(viewModel)
}
