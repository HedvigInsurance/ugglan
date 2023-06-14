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
    @Environment(\.hUseNewStyle) var hUseNewStyle

    @hColorBuilder var innerCircleColorOld: some hColor {
        if isRecording {
            hLabelColor.primary
        } else {
            hTintColor.red
        }
    }

    @hColorBuilder
    var getInnerCircleColor: some hColor {
        if hUseNewStyle {
            if isRecording {
                hLabelColor.primary
            } else {
                hBackgroundColorNew.signalBackground
            }
        } else {
            innerCircleColorOld
        }
    }

    @hColorBuilder
    var getBackgroundColor: some hColor {
        if hUseNewStyle {
            hBackgroundColorNew.primary
        } else {
            hBackgroundColor.secondary
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle().fill(getInnerCircleColor)
                .frame(width: 36, height: 36)
                .cornerRadius(isRecording ? 1 : 18)
                .padding(36)
        }
        .background(Circle().fill(getBackgroundColor))
        .shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 4)
    }
}
