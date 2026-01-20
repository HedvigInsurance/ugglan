import SwiftUI
import hCore
import hCoreUI

struct VoiceRecordingCardContent: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () -> Void
    let onStartOver: () -> Void
    let onUseText: () -> Void

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
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
                isRecording: voiceRecorder.isPlaying,
                maxHeight: 60
            )
        } else {
            IdleWaveformView()
        }
    }

    @ViewBuilder
    private var controlsSection: some View {
        HStack(spacing: .padding4) {
            // Start over button (left)
            VoiceStartOverButton(onTap: onStartOver)
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
    }

}
