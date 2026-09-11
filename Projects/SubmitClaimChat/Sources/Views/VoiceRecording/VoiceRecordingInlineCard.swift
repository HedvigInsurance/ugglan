import SwiftUI
import hCore
import hCoreUI

/// Inline version of `VoiceRecordingCardContent` for the redesigned description step:
/// title · timer · waveform · Börja om / Spela in / Skicka tiles, in a card docked in the chat.
struct VoiceRecordingInlineCard: View {
    @ObservedObject var voiceRecorder: VoiceRecorder
    let onSend: () async throws -> Void
    let onClose: () -> Void
    @State private var waveformWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                hText(L10n.claimsTriagingWhatHappenedTitle)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityHidden(voiceRecorder.isCountingDown || voiceRecorder.isRecording)
                hText(subtitle, style: .body1)
                    .foregroundColor(subtitleColor)
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
                // While sending the waveform stays, greyed out, and every tile is disabled.
                waveformSection
                    .padding(.horizontal, .padding8)
                    .padding(.vertical, .padding64)
                    .opacity(voiceRecorder.error != nil ? 0 : (voiceRecorder.isSending ? 0.35 : 1))
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
                VoiceSendButton(onTap: onSend)
            }
            // The tiles use Spacers internally (wrapContentForControlButton); keep them hugging.
            .fixedSize(horizontal: false, vertical: true)
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
        .modifier(SubmitClaimInputCardBackground())
        .disabled(voiceRecorder.isSending)
        .environmentObject(voiceRecorder)
        .animation(.easeInOut(duration: 0.2), value: voiceRecorder.error)
        .animation(.easeInOut(duration: 0.2), value: voiceRecorder.isSending)
    }

    private var subtitle: String {
        if voiceRecorder.isSending { return L10n.fileUploadIsUploading }
        return voiceRecorder.formattedTime ?? " "
    }

    @hColorBuilder
    private var subtitleColor: some hColor {
        if voiceRecorder.isSending {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Opaque.secondary
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
        .accessibilityAddTraits(isPlaybackMode ? [.isButton, .startsMediaSession] : [])
        .accessibilityLabel(isPlaybackMode ? L10n.voiceoverAudioRecordingPlay : L10n.a11YAudioRecording)
    }
}

#Preview {
    VStack {
        Spacer()
        VoiceRecordingInlineCard(voiceRecorder: VoiceRecorder(), onSend: {}, onClose: {})
            .padding(.horizontal, .padding16)
    }
}
