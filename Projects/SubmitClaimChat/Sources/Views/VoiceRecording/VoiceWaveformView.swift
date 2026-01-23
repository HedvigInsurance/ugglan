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
                        .fill(hTextColor.Opaque.primary)
                        .frame(
                            width: barWidth,
                            height: barHeight(for: level, at: index, total: levels.count)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: maxHeight)
        .animation(.easeOut(duration: 0.1), value: audioLevels)
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

    private func barHeight(for level: CGFloat, at index: Int, total: Int) -> CGFloat {
        // Apply edge fade effect - bars are shorter at the edges
        let edgeFadeWidth = min(10, total / 4)  // Fade over ~10 bars on each edge

        // Calculate edge multiplier: 0 at edges, 1.0 in the middle
        let edgeMultiplier: CGFloat
        if index < edgeFadeWidth {
            // Left edge fade in
            edgeMultiplier = CGFloat(index) / CGFloat(edgeFadeWidth)
        } else if index >= total - edgeFadeWidth {
            // Right edge fade out
            edgeMultiplier = CGFloat(total - index - 1) / CGFloat(edgeFadeWidth)
        } else {
            // Middle section - full height
            edgeMultiplier = 1.0
        }

        // Apply noise gate to filter background noise
        let noiseThreshold: CGFloat = 0.1
        let gatedLevel = level < noiseThreshold ? 0 : (level - noiseThreshold) / (1.0 - noiseThreshold)

        // Amplify to get taller bars while preserving variation
        let amplifiedLevel = min(1.0, pow(gatedLevel, 0.8) * 1.2)

        // Apply edge multiplier to the amplified level
        let adjustedLevel = amplifiedLevel * edgeMultiplier
        let height = max(minBarHeight * edgeMultiplier, adjustedLevel * maxHeight)
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
