import SwiftUI
import hCoreUI

public struct VoiceWaveformView: View {
    let audioLevels: [CGFloat]
    let isRecording: Bool
    let maxHeight: CGFloat

    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 2
    private let minBarHeight: CGFloat = 4

    public init(
        audioLevels: [CGFloat],
        isRecording: Bool,
        maxHeight: CGFloat = 40
    ) {
        self.audioLevels = audioLevels
        self.isRecording = isRecording
        self.maxHeight = maxHeight
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
            return Array(repeating: 0.1, count: count)
        }

        // Take the last N levels, pad with zeros if needed
        let levels = audioLevels.suffix(count)
        let padding = Array(repeating: CGFloat(0.1), count: max(0, count - levels.count))
        return padding + Array(levels)
    }

    private func barHeight(for level: CGFloat) -> CGFloat {
        let height = max(minBarHeight, level * maxHeight)
        return min(height, maxHeight)
    }
}

// MARK: - Animated Idle Waveform
public struct IdleWaveformView: View {
    @State private var animationPhase: CGFloat = 0

    private let barCount = 30
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 2
    private let maxHeight: CGFloat = 20
    private let minHeight: CGFloat = 4

    public init() {}

    public var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(hTextColor.Opaque.tertiary)
                    .frame(
                        width: barWidth,
                        height: barHeight(for: index)
                    )
            }
        }
        .frame(height: maxHeight)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let phase = animationPhase + CGFloat(index) * 0.3
        let wave = (sin(phase) + 1) / 2  // Normalize to 0...1
        return minHeight + wave * (maxHeight - minHeight) * 0.5
    }
}

#Preview("Recording") {
    VoiceWaveformView(
        audioLevels: (0..<50).map { _ in CGFloat.random(in: 0.1...1.0) },
        isRecording: true
    )
    .padding()
}

#Preview("Idle") {
    IdleWaveformView()
        .padding()
}
