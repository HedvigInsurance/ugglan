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
            hSection {
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
                .padding(.vertical, .padding8)
            }
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

    var buttonImage: some View {
        isRecording ? hCoreUIAssets.pause.view : hCoreUIAssets.mic.view
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceRecordButton(isRecording: false) {}
        VoiceRecordButton(isRecording: true) {}
    }
}
