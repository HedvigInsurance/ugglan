import SwiftUI
import hCore
import hCoreUI

/// Voice input for the description step (Figma "App P2 2026", section "5 · Text / voice input", section 3):
/// title · timer · waveform · Börja om / Spela in / Skicka tiles, in a card that replaces the docked input area.
struct VoiceRecordingCardContent: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () async throws -> Void
    let onClose: () -> Void
    @State private var waveformWidth: CGFloat = 0
    @State private var dragProgress: Double?
    @State private var timerHeight: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                hText(L10n.claimsTriagingWhatHappenedTitle)
                    .foregroundColor(titleColor)
                    .accessibilityHidden(voiceRecorder.isCountingDown || voiceRecorder.isRecording)
                Group {
                    if voiceRecorder.isSending {
                        // Figma 3.6: the timer reads "Skickar…" while the recording is uploaded.
                        hText(SubmitClaimAudioStepCopy.sending, style: .body1)
                            .foregroundColor(recordingProgressColor)
                    } else if let formattedTimeSeconds = voiceRecorder.formattedTimeSeconds,
                        let formattedTimeMinutes = voiceRecorder.formattedTimeMinutes
                    {
                        HStack(spacing: 0) {
                            hText(formattedTimeMinutes)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            hText(":")
                            hText(formattedTimeSeconds)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .hTextStyle(.body1)
                        .foregroundColor(recordingProgressColor)
                        .accessibilityHidden(true)
                    } else {
                        hText(" ", style: .body1)
                            .foregroundColor(recordingProgressColor)
                            .accessibilityHidden(true)
                    }
                }
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                timerHeight = proxy.size.height
                            }
                            .onChange(of: proxy.size) { value in
                                timerHeight = value.height
                            }
                    }
                }
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
                // Figma 3.6: while sending the waveform stays, greyed out, and every tile reads disabled.
                waveformSection
                    .padding(.horizontal, .padding8)
                    .padding(.bottom, .padding64)
                    .padding(.top, max(.padding64 - timerHeight, 0))
                    .opacity(voiceRecorder.error != nil ? 0 : (voiceRecorder.isSending ? 0.35 : 1))
                    .animation(.defaultSpring, value: voiceRecorder.hasRecording)
                    .accessibilityHidden(
                        voiceRecorder.isCountingDown || voiceRecorder.isRecording || !voiceRecorder.hasRecording
                    )
            }
            controlsSection
        }
        .padding(.padding16)
        .overlay(alignment: .topTrailing) {
            if !voiceRecorder.isSending {
                Button(action: onClose) {
                    hCoreUIAssets.close.view
                        .foregroundColor(hFillColor.Opaque.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .padding(.padding6)
                .accessibilityLabel(L10n.a11YClose)
            }
        }
        .claimInputCardBackground()
        .animation(.easeInOut(duration: 0.2), value: voiceRecorder.error)
        .animation(.easeInOut(duration: 0.2), value: voiceRecorder.isSending)
        .disabled(voiceRecorder.isSending)
        .environmentObject(voiceRecorder)
    }

    @hColorBuilder
    private var titleColor: some hColor {
        if !voiceRecorder.isSending {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.disabled
        }
    }

    @hColorBuilder
    private var recordingProgressColor: some hColor {
        if !voiceRecorder.isSending {
            hTextColor.Opaque.secondary
        } else {
            hTextColor.Opaque.disabled
        }
    }

    private var isPlaybackMode: Bool {
        voiceRecorder.hasRecording && !voiceRecorder.isRecording
    }

    private var audioLevelsBinding: Binding<[CGFloat]> {
        Binding(
            get: { voiceRecorder.audioLevels },
            set: { _ in }
        )
    }

    private var isRecordingBinding: Binding<Bool> {
        Binding(
            get: { voiceRecorder.isRecording },
            set: { _ in }
        )
    }

    private var waveformSection: some View {
        VoiceWaveformView(
            audioLevels: audioLevelsBinding,
            isRecording: isRecordingBinding,
            progress: isPlaybackMode ? (dragProgress ?? voiceRecorder.progress) : nil
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        waveformWidth = geo.size.width
                    }
                    .onChange(of: geo.size) { size in
                        waveformWidth = size.width
                    }
            }
        )
        .onTapGesture { location in
            guard isPlaybackMode else { return }
            // Calculate progress based on tap position
            let progress = location.x / waveformWidth
            let finalProgress = min(max(progress, 0), 1)

            // Seek to tapped position
            voiceRecorder.setProgress(to: finalProgress)

            // Start playback if not already playing
            if !voiceRecorder.isPlaying {
                voiceRecorder.startPlayback()
            }
        }
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { gesture in
                    guard isPlaybackMode else { return }
                    // On the very first drag event, pause if currently playing
                    if dragProgress == nil && voiceRecorder.isPlaying {
                        voiceRecorder.pausePlayback()
                    }

                    // Only update visual progress, don't seek audio yet
                    let gesturePosition = gesture.startLocation.x + gesture.translation.width
                    let progress = Double(gesturePosition / waveformWidth)
                    dragProgress = min(max(progress, 0), 1)
                }
                .onEnded { gesture in
                    guard isPlaybackMode else { return }
                    let gesturePosition = gesture.startLocation.x + gesture.translation.width
                    let progress = gesturePosition / waveformWidth
                    let finalProgress = min(max(progress, 0), 1)

                    // Seek to final position and start playing
                    voiceRecorder.setProgress(to: finalProgress)
                    dragProgress = nil
                    voiceRecorder.startPlayback()
                }
        )
        .accessibilityElement(children: isPlaybackMode ? .ignore : .combine)
        .accessibilityLabel(waveformAccessibilityLabel)
        .accessibilityValue(voiceRecorder.formattedTime ?? "")
        .modifier(PlaybackAccessibilityModifier(isPlaybackMode: isPlaybackMode, voiceRecorder: voiceRecorder))
    }

    private var waveformAccessibilityLabel: String {
        if isPlaybackMode {
            return L10n.voiceoverAudioRecordingPlay
        } else if voiceRecorder.isRecording {
            return L10n.claimChatRecordingTitle
        } else {
            return L10n.a11YAudioRecording
        }
    }

    private var controlsSection: some View {
        HStack(spacing: .padding4) {
            Group {
                VoiceStartOverButton()
                if !voiceRecorder.hasRecording {
                    VoiceRecordButton()
                } else {
                    VoicePlaybackButton()
                }
            }
            .opacity(voiceRecorder.isSending ? 0.4 : 1)
            VoiceSendButton(
                onTap: onSend
            )
        }
        // The tiles use Spacers internally (wrapContentForControlButton); keep them hugging.
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct PlaybackAccessibilityModifier: ViewModifier {
    let isPlaybackMode: Bool
    let voiceRecorder: VoiceRecorder

    private var accessibilityTraits: AccessibilityTraits {
        if isPlaybackMode {
            return [.isButton, .startsMediaSession, .playsSound]
        } else if voiceRecorder.isRecording {
            return .updatesFrequently
        }
        return []
    }

    func body(content: Content) -> some View {
        content
            .accessibilityHint(isPlaybackMode ? L10n.voiceoverAudioRecordingPlay : "")
            .accessibilityAddTraits(accessibilityTraits)
            .accessibilityAction {
                if isPlaybackMode {
                    voiceRecorder.togglePlayback()
                }
            }
    }
}

#Preview("Voice card") {
    VStack {
        Spacer()
        VoiceRecordingCardContent(voiceRecorder: VoiceRecorder(), onSend: {}, onClose: {})
            .padding(.horizontal, .padding16)
    }
}

#Preview("Voice card · sending") {
    let voiceRecorder = VoiceRecorder()
    voiceRecorder.isSending = true
    return VStack {
        Spacer()
        VoiceRecordingCardContent(voiceRecorder: voiceRecorder, onSend: {}, onClose: {})
            .padding(.horizontal, .padding16)
    }
}
