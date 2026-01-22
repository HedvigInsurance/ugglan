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
                                .opacity(voiceRecorder.isSending ? 0 : 1)
                        }
                    }
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
        GeometryReader { geometry in
            let waveform = VoiceWaveformView(
                audioLevels: voiceRecorder.audioLevels,
                isRecording: voiceRecorder.isRecording,
                maxHeight: 60,
                progress: dragProgress ?? (voiceRecorder.hasRecording ? voiceRecorder.progress : nil)
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

            if voiceRecorder.hasRecording && !voiceRecorder.isRecording {
                waveform
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
                                let progress = gesturePosition / waveformWidth
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
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            voiceRecorder.setProgress(to: min(voiceRecorder.progress + 0.1, 1.0))
                        case .decrement:
                            voiceRecorder.setProgress(to: max(voiceRecorder.progress - 0.1, 0.0))
                        @unknown default:
                            break
                        }
                    }
            } else {
                waveform
            }
        }
    }

    private var controlsSection: some View {
        HStack(spacing: .padding4) {
            VoiceStartOverButton(
                onTap: { [weak voiceRecorder] in
                    voiceRecorder?.startOver()
                },
                isEnabled: voiceRecorder.hasRecording
            )

            if !voiceRecorder.hasRecording {
                VoiceRecordButton(isRecording: voiceRecorder.isRecording) { [weak voiceRecorder] in
                    Task {
                        await voiceRecorder?.toggleRecording()
                    }
                }
            } else {
                VoicePlaybackButton(isPlaying: voiceRecorder.isPlaying) { [weak voiceRecorder] in
                    voiceRecorder?.togglePlayback()
                }
            }
            VoiceSendButton(
                onTap: onSend,
                isEnabled: voiceRecorder.hasRecording
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
