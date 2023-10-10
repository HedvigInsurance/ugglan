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

    @hColorBuilder
    var getInnerCircleColor: some hColor {
        if isRecording {
            innerRectangleRecordingColorScheme
        } else {
            hSignalColor.redElement
        }
    }

    private let innerRectangleRecordingColorScheme: some hColor = hColorScheme.init(
        light: hTextColor.primary,
        dark: hTextColor.negative
    )

    @hColorBuilder
    private var outerCircleRecordingColorScheme: some hColor {
        if isRecording {
            hColorScheme.init(
                light: hTextColor.negative,
                dark: hTextColor.primary
            )
        } else {
            hColorScheme.init(
                light: hTextColor.negative,
                dark: hGrayscaleColor.greyScale900
            )
        }
    }

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle().fill(getInnerCircleColor)
                .frame(width: isRecording ? 16 : 36, height: isRecording ? 16 : 36)
                .cornerRadius(isRecording ? 1 : 18)
                .padding(isRecording ? 22 : 18)
        }
        .background(Circle().fill(outerCircleRecordingColorScheme))
        .shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 4)
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordButton(isRecording: true) {}
            .environmentObject(AudioRecorder())
    }
}
