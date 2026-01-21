import SwiftUI
import hCore
import hCoreUI

struct VoiceRecordingCardContent: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () -> Void

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    VStack(spacing: 0) {
                        hText(L10n.claimsTriagingWhatHappenedTitle)
                        hText(voiceRecorder.formattedTime, style: .body1)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }

                    waveformSection
                        .frame(height: .padding60)
                        .padding(.horizontal, .padding45)

                    controlsSection
                        .sectionContainerStyle(.opaque)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)
            .padding(.top, .padding32)
        }
        .hFormContentPosition(.compact)
    }

    @ViewBuilder
    private var waveformSection: some View {
        VoiceWaveformView(
            audioLevels: voiceRecorder.audioLevels,
            isRecording: voiceRecorder.isRecording,
            maxHeight: 60
        )
    }

    @ViewBuilder
    private var controlsSection: some View {
        HStack(spacing: .padding4) {
            VoiceStartOverButton {
                voiceRecorder.startOver()
            }
            .disabled(!voiceRecorder.hasRecording)

            if !voiceRecorder.hasRecording {
                VoiceRecordButton(isRecording: voiceRecorder.isRecording) {
                    Task {
                        await voiceRecorder.toggleRecording()
                    }
                }
            } else {
                VoicePlaybackButton(isPlaying: voiceRecorder.isPlaying) {
                    voiceRecorder.togglePlayback()
                }
            }

            // Send button (right)
            VoiceSendButton(onTap: onSend)
                .disabled(!voiceRecorder.hasRecording)
        }
        .frame(maxWidth: 600)
    }
}

#Preview {
    VoiceRecordingCardContent(voiceRecorder: .init()) {
    }
}
