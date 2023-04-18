import SwiftUI
import hCoreUI

struct RecordButton: View {
    var isRecording: Bool
    var onTap: () -> Void

    @ViewBuilder var pulseBackground: some View {
        if isRecording {
            AudioPulseBackground()
        } else {
            Color.clear
        }
    }

    var body: some View {
        ZStack {
            pulseBackground
            SwiftUI.Button {
                onTap()
            } label: {

            }
            .buttonStyle(RecordButtonStyle(isRecording: isRecording))
        }
    }
}

struct RecordButtonStyle: SwiftUI.ButtonStyle {
    var isRecording: Bool

    @hColorBuilder var innerCircleColor: some hColor {
        if isRecording {
            hLabelColor.primary
        } else {
            hTintColor.red
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle().fill(innerCircleColor).frame(width: 36, height: 36)
                .cornerRadius(isRecording ? 1 : 18)
                .padding(36)
        }
        .background(Circle().fill(hBackgroundColor.secondary))
        .shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 4)
    }
}
