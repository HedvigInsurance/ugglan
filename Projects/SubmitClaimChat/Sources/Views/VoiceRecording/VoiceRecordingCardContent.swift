import SwiftUI
import hCore
import hCoreUI

struct VoiceRecordingCardContent: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () async throws -> Void
    @State private var waveformWidth: CGFloat = 0
    @State private var dragProgress: Double?

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        hText(L10n.claimsTriagingWhatHappenedTitle)
                            .foregroundColor(titleColor)
                            .accessibilityHidden(voiceRecorder.isCountingDown || voiceRecorder.isRecording)
                        if let formattedTimeSeconds = voiceRecorder.formattedTimeSeconds,
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
                    .opacity(voiceRecorder.error != nil ? 0 : 1)

                    ZStack {
                        if let error = voiceRecorder.error {
                            StateView(
                                type: .error,
                                title: error.title ?? L10n.somethingWentWrong,
                                bodyText: error.errorDescription,
                                formPosition: nil,
                                attachContentToBottom: false
                            )
                            .offset(x: 0, y: -.padding32)
                            .transition(.opacity)
                        }
                        if voiceRecorder.isSending {
                            DotsActivityIndicator(.standard)
                                .useDarkColor
                        }
                        waveformSection
                            .padding(.horizontal, .padding45)
                            .padding(.vertical, .padding64)
                            .opacity(voiceRecorder.isSending || voiceRecorder.error != nil ? 0 : 1)
                            .animation(.defaultSpring, value: voiceRecorder.hasRecording)
                            .accessibilityHidden(
                                voiceRecorder.isCountingDown || voiceRecorder.isRecording || !voiceRecorder.hasRecording
                            )
                    }
                    controlsSection
                }
                .animation(.easeInOut(duration: 0.2), value: voiceRecorder.error)
                .animation(.easeInOut(duration: 0.2), value: voiceRecorder.isSending)
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)
            .padding(.top, .padding32)
        }
        .hFormContentPosition(.compact)
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
            VoiceStartOverButton()
            if !voiceRecorder.hasRecording {
                VoiceRecordButton()
            } else {
                VoicePlaybackButton()
            }
            VoiceSendButton(
                onTap: onSend
            )
        }
        .frame(maxWidth: 600)
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

#Preview {
    let voiceRecoder = VoiceRecorder()
    voiceRecoder.isSending = true
    return VoiceRecordingCardContent(voiceRecorder: voiceRecoder) {
    }
}
