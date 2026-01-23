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
                VStack(spacing: .padding16) {
                    Group {
                        if let error = voiceRecorder.error {
                            StateView(
                                type: .error,
                                title: error.title ?? L10n.somethingWentWrong,
                                bodyText: error.errorDescription,
                                formPosition: nil,
                                attachContentToBottom: false
                            )
                        } else {
                            VStack(spacing: 0) {
                                hText(L10n.claimsTriagingWhatHappenedTitle)
                                    .foregroundColor(titleColor)

                                hText(voiceRecorder.formattedTime, style: .body1)
                                    .foregroundColor(recordingProgressColor)
                            }
                            ZStack {
                                if voiceRecorder.isSending {
                                    DotsActivityIndicator(.standard)
                                        .useDarkColor
                                }
                                waveformSection
                                    .frame(height: .padding60)
                                    .padding(.horizontal, .padding45)
                                    .padding(.vertical, .padding48)
                                    .opacity(voiceRecorder.isSending ? 0 : 1)
                                    .animation(.defaultSpring, value: voiceRecorder.hasRecording)
                            }
                        }
                    }
                    .accessibilityHidden(voiceRecorder.isCountingDown)

                    controlsSection
                }
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

    @ViewBuilder
    private var waveformSection: some View {
        if voiceRecorder.hasRecording && !voiceRecorder.isRecording {
            FixedDotsWaveformView(
                audioLevels: voiceRecorder.audioLevels,
                maxHeight: 60,
                progress: dragProgress ?? (voiceRecorder.hasRecording ? voiceRecorder.progress : nil)
            )
            .transition(.opacity)
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
                        let gesturePosition = gesture.startLocation.x + gesture.translation.width
                        let progress = gesturePosition / waveformWidth
                        let finalProgress = min(max(progress, 0), 1)

                        // Seek to final position and start playing
                        voiceRecorder.setProgress(to: finalProgress)
                        dragProgress = nil
                        voiceRecorder.startPlayback()
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.voiceoverAudioRecordingPlay)
            .accessibilityValue(voiceRecorder.formattedTime)
            .accessibilityHint(L10n.voiceoverAudioRecordingPlay)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                voiceRecorder.togglePlayback()
            }
        } else if voiceRecorder.isRecording {
            VoiceWaveformView(
                audioLevels: voiceRecorder.audioLevels,
                isRecording: voiceRecorder.isRecording,
                maxHeight: 60
            )
            .accessibilityLabel(L10n.claimChatRecordingTitle)
            .accessibilityValue(voiceRecorder.formattedTime)
            .accessibilityAddTraits(.updatesFrequently)
        } else {
            VoiceWaveformView(
                audioLevels: voiceRecorder.audioLevels,
                isRecording: voiceRecorder.isRecording,
                maxHeight: 60
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(L10n.a11YAudioRecording)
            .accessibilityHint(L10n.claimsStartRecordingLabel)
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

#Preview {
    let voiceRecoder = VoiceRecorder()
    voiceRecoder.isSending = true
    return VoiceRecordingCardContent(voiceRecorder: voiceRecoder) {
    }
}
