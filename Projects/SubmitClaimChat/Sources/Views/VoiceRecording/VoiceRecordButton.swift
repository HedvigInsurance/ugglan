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
                        .foregroundColor(hFillColor.Opaque.white)
                }
                .scaleEffect(buttonScale)
                hText(
                    voiceRecorder.isRecording || voiceRecorder.isCountingDown
                        ? L10n.audioRecorderStop : L10n.audioRecorderStart,
                    style: .label
                )
                .transition(.scale)
            }
            .wrapContentForControlButton()
        }
        .animation(.defaultSpring, value: buttonScale)
        .animation(.defaultSpring, value: voiceRecorder.isRecording)
        .animation(.defaultSpring, value: voiceRecorder.isCountingDown)
        .buttonStyle(.plain)
        .accessibilityLabel(voiceRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
        .accessibilityAddTraits(.isButton)
        .onChange(of: countdownNumber) { _ in
            buttonScale = 1.3
            Task {
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.hapticDelay)
                buttonScale = 1.0
            }
        }
    }

    private func handleTap() {
        ImpactGenerator.soft()
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
                await delay(0.2)
            }

            try Task.checkCancellation()
            if voiceOverEnabled {
                await postAccessibilityAnnouncementAndWait(L10n.voiceoverAudioCountdown)
            }
            try Task.checkCancellation()
            for number in (1...3).reversed() {
                countdownNumber = number
                if voiceOverEnabled {
                    await withMinimumDuration(seconds: 1) {
                        await postAccessibilityAnnouncementAndWait("\(number)")
                    }
                } else {
                    await delay(TimeInterval(ClaimChatConstants.Timing.countdownStep))
                }
                try Task.checkCancellation()
                ImpactGenerator.light()
            }
            try Task.checkCancellation()

            if voiceOverEnabled {
                await postAccessibilityAnnouncementAndWait(
                    L10n.voiceoverDoubleClickTo + " " + L10n.audioRecorderStop
                )
            }

            try Task.checkCancellation()
            if voiceRecorder.isCountingDown == true {
                voiceRecorder.isCountingDown = false
                await voiceRecorder.toggleRecording()
            }
            countdownNumber = nil
        }
    }

    /// Runs an async operation but ensures at least `seconds` have elapsed before returning.
    private func withMinimumDuration(seconds: TimeInterval, operation: @escaping @Sendable () async -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await operation() }
            group.addTask { await delay(seconds) }
            for await _ in group {}
        }
    }

    /// Posts a VoiceOver announcement and suspends until VoiceOver finishes speaking it.
    private func postAccessibilityAnnouncementAndWait(_ message: String) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let observerRef = ObserverRef()
            observerRef.value = NotificationCenter.default.addObserver(
                forName: UIAccessibility.announcementDidFinishNotification,
                object: nil,
                queue: .main
            ) { _ in
                if let obs = observerRef.value { NotificationCenter.default.removeObserver(obs) }
                continuation.resume()
            }
            UIAccessibility.post(notification: .announcement, argument: message)
        }
        await delay(0.2)  // buffer after announcement
    }

    private final class ObserverRef: @unchecked Sendable {
        var value: NSObjectProtocol?
    }

    var buttonImage: some View {
        Group {
            if let number = countdownNumber {
                hText("\(number)", style: .label)
            } else {
                if voiceRecorder.isRecording {
                    hCoreUIAssets.stop.view
                        .frame(width: 12, height: 12)
                } else {
                    hCoreUIAssets.mic.view
                }
            }
        }
    }
}
