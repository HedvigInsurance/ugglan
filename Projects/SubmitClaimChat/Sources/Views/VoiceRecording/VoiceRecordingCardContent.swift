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
                isRecording: false,
                maxHeight: 60
            )
        } else {
            IdleWaveformView()
        }
    }

    private var controlsSection: some View {
        HStack(spacing: .padding16) {
            // Start over button (left)
            if voiceRecorder.hasRecording {
                Button(action: onStartOver) {
                    hText(L10n.embarkRecordAgain, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Button(action: onUseText) {
                    hText(L10n.claimsUseTextInstead, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Record button (center)
            VoiceRecordButton(isRecording: voiceRecorder.isRecording) {
                Task {
                    await voiceRecorder.toggleRecording()
                }
            }

            // Send button (right)
            Button(action: onSend) {
                hText(L10n.chatUploadPresend, style: .body1)
                    .foregroundColor(uploadTextColor)
                    .padding(.horizontal, .padding16)
                    .padding(.vertical, .padding8)
                    .background(
                        Capsule()
                            .fill(uploadCapsuleColor)
                    )
            }
            .disabled(!voiceRecorder.hasRecording)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @hColorBuilder
    private var uploadTextColor: some hColor {
        if voiceRecorder.hasRecording {
            hTextColor.Opaque.negative
        } else {
            hTextColor.Opaque.tertiary
        }
    }

    @hColorBuilder
    private var uploadCapsuleColor: some hColor {
        if voiceRecorder.hasRecording {
            hSignalColor.Blue.element
        } else {
            hFillColor.Opaque.disabled
        }
    }
}
