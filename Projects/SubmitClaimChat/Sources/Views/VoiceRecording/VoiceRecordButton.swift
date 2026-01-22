import SwiftUI
import hCore
import hCoreUI

public struct VoiceRecordButton: View {
    let isRecording: Bool
    let onTap: () -> Void

    @State private var countdownNumber: Int? = nil

    @EnvironmentObject var voiceRecorder: VoiceRecorder

    public init(isRecording: Bool, onTap: @escaping () -> Void) {
        self.isRecording = isRecording
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: handleTap) {
            VStack(spacing: .padding4) {
                ZStack {
                    Circle()
                        .fill(hSignalColor.Red.element)
                        .frame(width: 32, height: 32)

                    buttonImage
                        .foregroundColor(hFillColor.Opaque.negative)
                }

                hText(isRecording ? L10n.audioRecorderStop : L10n.audioRecorderStart, style: .label)
            }
            .wrapContentForControlButton()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
        .accessibilityAddTraits(.isButton)
    }

    private func handleTap() {
        if isRecording {
            onTap()
        } else if !voiceRecorder.isCountingDown {
            Task {
                try await voiceRecorder.askForPermissionIfNeeded()
                startCountdown()
            }
        }
    }

    private func startCountdown() {
        voiceRecorder.isCountingDown = true

        Task {
            // Small delay to let SwiftUI update accessibility tree before announcements
            try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds

            UIAccessibility.post(
                notification: .announcement,
                argument: L10n.voiceoverAudioCountdown
            )
            try? await Task.sleep(nanoseconds: 1_200_000_000)  // 1.2 seconds to let VoiceOver finish speaking

            for number in (1...3).reversed() {
                countdownNumber = number
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "\(number)"
                )
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
            }

            countdownNumber = nil
            voiceRecorder.isCountingDown = false
            onTap()
        }
    }

    var buttonImage: some View {
        Group {
            if let number = countdownNumber {
                hText("\(number)", style: .label)
            } else {
                isRecording ? hCoreUIAssets.pause.view : hCoreUIAssets.mic.view
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceRecordButton(isRecording: false) {}
        VoiceRecordButton(isRecording: true) {}
    }
}
