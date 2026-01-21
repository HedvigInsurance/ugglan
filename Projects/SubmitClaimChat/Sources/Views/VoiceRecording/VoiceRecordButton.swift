import SwiftUI
import hCore
import hCoreUI

public struct VoiceRecordButton: View {
    let isRecording: Bool
    let onTap: () -> Void

    @State private var countdownNumber: Int? = nil
    @State private var isCountingDown = false

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

                hText(isRecording ? "Stop" : "Start", style: .label)
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
        } else if !isCountingDown {
            Task {
                try await voiceRecorder.askForPermissionIfNeeded()
                startCountdown()
            }
        }
    }

    private func startCountdown() {
        isCountingDown = true

        Task {
            for number in (1...3).reversed() {
                countdownNumber = number
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
            }

            countdownNumber = nil
            isCountingDown = false
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
