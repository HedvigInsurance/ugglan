import SwiftUI
import hCoreUI

public struct VoiceWaveformView: View {
    let audioLevels: [CGFloat]
    let isRecording: Bool
    let maxHeight: CGFloat

    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 2
    private let minBarHeight: CGFloat

    public init(
        audioLevels: [CGFloat],
        isRecording: Bool,
        maxHeight: CGFloat = 60,
        minBarHeight: CGFloat = 2
    ) {
        self.audioLevels = audioLevels
        self.isRecording = isRecording
        self.maxHeight = maxHeight
        self.minBarHeight = minBarHeight
    }

    public var body: some View {
        GeometryReader { geometry in
            let maxBars = Int(geometry.size.width / (barWidth + barSpacing))
            let levels = prepareLevels(count: maxBars)

            HStack(spacing: barSpacing) {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                    RoundedRectangle(cornerRadius: barWidth / 2)
                        .fill(hTextColor.Opaque.secondary)
                        .frame(
                            width: barWidth,
                            height: barHeight(for: level)
                        )
                        .animation(.easeOut(duration: 0.1), value: level)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: maxHeight)
    }

    private func prepareLevels(count: Int) -> [CGFloat] {
        if audioLevels.isEmpty {
            // Show static bars when not recording
            return Array(repeating: 0, count: count)
        }

        // Take the last N levels, pad with zeros if needed
        let levels = audioLevels.suffix(count)
        let padding = Array(repeating: CGFloat(0), count: max(0, count - levels.count))
        return padding + Array(levels)
    }

    private func barHeight(for level: CGFloat) -> CGFloat {
        let height = max(minBarHeight, level * maxHeight)
        return min(height, maxHeight)
    }
}

#Preview("Recording") {
    VoiceWaveformView(
        audioLevels: (0..<50).map { _ in CGFloat.random(in: 0...1.0) },
        isRecording: true
    )
    .padding()
}

#Preview("Idle") {
    VoiceWaveformView(
        audioLevels: [],
        isRecording: false
    )
    .padding()
}
