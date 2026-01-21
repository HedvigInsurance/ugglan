import SwiftUI
import hCore
import hCoreUI

struct VoiceRecordingCardContent: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () async throws -> Void

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
        VoiceWaveformView(
            audioLevels: voiceRecorder.audioLevels,
            isRecording: voiceRecorder.isRecording,
            maxHeight: 60
        )
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
