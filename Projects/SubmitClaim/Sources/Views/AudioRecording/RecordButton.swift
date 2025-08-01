import hCoreUI
import SwiftUI

public struct RecordButton: View {
    var isRecording: Bool
    var onTap: () -> Void

    public init(
        isRecording: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        self.isRecording = isRecording
        self.onTap = onTap
    }

    @ViewBuilder var pulseBackground: some View {
        if isRecording {
            AudioPulseBackground()
        } else {
            Color.clear
        }
    }

    public var body: some View {
        ZStack {
            pulseBackground
            SwiftUI.Button {
                onTap()
            } label: {}
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
            hSignalColor.Red.element
        }
    }

    private let innerRectangleRecordingColorScheme: some hColor = hColorScheme.init(
        light: hTextColor.Opaque.primary,
        dark: hTextColor.Opaque.negative
    )

    @hColorBuilder
    private var outerCircleRecordingColorScheme: some hColor {
        hBackgroundColor.white
    }

    @ViewBuilder
    func makeBody(configuration _: Configuration) -> some View {
        VStack {
            Rectangle().fill(getInnerCircleColor)
                .frame(width: isRecording ? 24 : 32, height: isRecording ? 24 : 32)
                .cornerRadius(isRecording ? .cornerRadiusXS : 16)
                .padding(isRecording ? 24 : 20)
        }
        .background(Circle().fill(outerCircleRecordingColorScheme))
        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: !isRecording)
        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: !isRecording)
        .overlay {
            Circle()
                .inset(by: -0.5)
                .strokeBorder(hBorderColor.primary, lineWidth: isRecording ? 0 : 1)
        }
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        let tempDir = FileManager.default.temporaryDirectory
        let path = tempDir.appendingPathComponent("path.m4a")

        return VStack {
            VStack {
                RecordButton(isRecording: false) {}
                    .environmentObject(AudioRecorder(filePath: path))
                RecordButton(isRecording: true) {}
                    .environmentObject(AudioRecorder(filePath: path))
            }
            .background(hBackgroundColor.primary)
            .colorScheme(.light)
            VStack {
                RecordButton(isRecording: false) {}
                    .environmentObject(AudioRecorder(filePath: path))
                RecordButton(isRecording: true) {}
                    .environmentObject(AudioRecorder(filePath: path))
            }
            .background(hBackgroundColor.primary)
            .colorScheme(.dark)
        }
    }
}
