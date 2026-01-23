import SwiftUI
import hCore
import hCoreUI

struct VoiceRecordButton: View {
    @State private var countdownNumber: Int? = nil
    @State private var buttonScale: CGFloat = 1.0

    @EnvironmentObject var voiceRecorder: VoiceRecorder
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    var body: some View {
        Button(action: handleTap) {
            VStack(spacing: .padding4) {
                ZStack {
                    Circle()
                        .fill(hSignalColor.Red.element)
                        .frame(width: 32, height: 32)

                    buttonImage
                        .foregroundColor(hFillColor.Opaque.negative)
                }
                .scaleEffect(buttonScale)
                hText(voiceRecorder.isRecording ? L10n.audioRecorderStop : L10n.audioRecorderStart, style: .label)
            }
            .wrapContentForControlButton()
        }
        .animation(.defaultSpring, value: buttonScale)
        .animation(.defaultSpring, value: voiceRecorder.isRecording)
        .buttonStyle(.plain)
        .accessibilityLabel(voiceRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
        .accessibilityAddTraits(.isButton)
        .onChange(of: countdownNumber) { _ in
            buttonScale = 1.2
            Task {
                try? await Task.sleep(seconds: 0.15)
                buttonScale = 1.0
            }
        }
    }

    private func handleTap() {
        if voiceRecorder.isRecording {
            Task {
                await voiceRecorder.toggleRecording()
            }
        } else if countdownNumber != nil {
            startCountdownTask?.cancel()
            voiceRecorder.isCountingDown = false
            countdownNumber = nil
        } else {
            Task {
                try await voiceRecorder.askForPermissionIfNeeded()
                startCountdown()
            }
        }
    }

    @State var startCountdownTask: Task<(), Error>?
    private func startCountdown() {
        voiceRecorder.isCountingDown = true

        startCountdownTask = Task {
            // Small delay to let SwiftUI update accessibility tree before announcements
            if voiceOverEnabled {
                try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds
            }

            try Task.checkCancellation()
            UIAccessibility.post(
                notification: .announcement,
                argument: L10n.voiceoverAudioCountdown
            )
            if voiceOverEnabled {
                try? await Task.sleep(nanoseconds: 1_200_000_000)  // 1.2 seconds to let VoiceOver finish speaking
            }
            try Task.checkCancellation()
            for number in (1...3).reversed() {
                countdownNumber = number
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "\(number)"
                )
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                try Task.checkCancellation()
            }
            try Task.checkCancellation()
            countdownNumber = nil
            voiceRecorder.isCountingDown = false
            await voiceRecorder.toggleRecording()
        }
    }

    var buttonImage: some View {
        Group {
            if let number = countdownNumber {
                hText("\(number)", style: .label)
            } else {
                voiceRecorder.isRecording ? hCoreUIAssets.pause.view : hCoreUIAssets.mic.view
            }
        }
    }
}
