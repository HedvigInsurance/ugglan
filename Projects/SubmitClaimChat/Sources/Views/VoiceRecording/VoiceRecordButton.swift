import SwiftUI
import hCore
import hCoreUI

public struct VoiceRecordButton: View {
    let isRecording: Bool
    let onTap: () -> Void

    @State private var pulseScale: CGFloat = 1.0

    public init(isRecording: Bool, onTap: @escaping () -> Void) {
        self.isRecording = isRecording
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            ZStack {
                // Pulse animation when recording
                if isRecording {
                    Circle()
                        .fill(hSignalColor.Red.element.opacity(0.2))
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                }

                // Outer circle
                Circle()
                    .fill(hBackgroundColor.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .strokeBorder(hBorderColor.primary, lineWidth: isRecording ? 0 : 1)
                    )

                // Inner shape (circle when not recording, rounded square when recording)
                if isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hTextColor.Opaque.primary)
                        .frame(width: 24, height: 24)
                } else {
                    Circle()
                        .fill(hSignalColor.Red.element)
                        .frame(width: 32, height: 32)
                }
            }
            .frame(width: 72, height: 72)
        }
        .buttonStyle(.plain)
        .onAppear {
            if isRecording {
                pulseScale = 1.3
            }
        }
        .onChange(of: isRecording) { recording in
            pulseScale = recording ? 1.3 : 1.0
        }
        .accessibilityLabel(isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceRecordButton(isRecording: false) {}
        VoiceRecordButton(isRecording: true) {}
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
