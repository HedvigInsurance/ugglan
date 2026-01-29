import SwiftUI
import hCoreUI

public struct VoiceWaveformView: View {
    @Binding var audioLevels: [CGFloat]
    @Binding var isRecording: Bool
    let maxHeight: CGFloat
    let progress: Double?

    private let dotSize: CGFloat = 2
    private let dotSpacing: CGFloat = 2
    private let minDotHeight: CGFloat = 2

    @State private var width: CGFloat = 0
    @State private var heights: [CGFloat] = []

    public init(
        audioLevels: Binding<[CGFloat]>,
        isRecording: Binding<Bool>,
        maxHeight: CGFloat = 30,
        progress: Double? = nil
    ) {
        self._audioLevels = audioLevels
        self._isRecording = isRecording
        self.maxHeight = maxHeight
        self.progress = progress
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                waveform
            }
            .frame(maxWidth: .infinity, alignment: isRecording ? .center : .leading)
            .onAppear {
                width = geometry.size.width
            }
            .onChange(of: geometry.size) { size in
                width = size.width
            }
            .onChange(of: width) { value in
                updateHeights()
            }
            .onChange(of: audioLevels) { _ in
                updateHeights()
            }
            .onChange(of: isRecording) { isRecording in
                updateHeights()
            }
        }
        .frame(height: maxHeight)
    }

    private func updateHeights() {
        let dotCount = calculateDotCount(for: width)
        let levels = prepareLevels(count: dotCount)
        withAnimation(.easeOut(duration: 0.15)) {
            heights = levels.enumerated()
                .map { index, level in
                    dotHeight(for: level, at: index, total: dotCount)
                }
        }
    }

    private var waveform: some View {
        ZStack(alignment: .leading) {
            // Base layer - primary color
            dotsView(color: hTextColor.Opaque.primary)

            // Progress layer - tertiary color with mask (only for playback mode)
            if let progress, !isRecording {
                dotsView(color: hTextColor.Opaque.tertiary)
                    .mask(
                        GeometryReader { geo in
                            Rectangle()
                                .frame(width: geo.size.width * progress)
                        }
                    )
            }
        }
    }

    private func dotsView(color: some hColor) -> some View {
        VStack {
            Spacer(minLength: 0)
            HStack(spacing: dotSpacing) {
                ForEach(Array(heights.enumerated()), id: \.offset) { index, height in
                    RoundedRectangle(cornerRadius: dotSize / 2)
                        .fill(color)
                        .frame(
                            width: dotSize,
                            height: height
                        )
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func calculateDotCount(for width: CGFloat) -> Int {
        max(1, Int(width / (dotSize + dotSpacing)))
    }

    private func prepareLevels(count: Int) -> [CGFloat] {
        if audioLevels.isEmpty {
            return Array(repeating: 0, count: count)
        }

        if isRecording {
            // For recording: all dots based on last audio level with random variation
            let lastLevel = audioLevels.last ?? 0
            return (0..<count)
                .map { _ in
                    let randomVariation = CGFloat.random(in: 0.4...1.0)
                    return lastLevel * randomVariation
                }
        } else {
            // For playback: resample all levels to fit the available dots
            return resampleLevels(to: count)
        }
    }

    private func resampleLevels(to targetCount: Int) -> [CGFloat] {
        let sourceCount = audioLevels.count

        if sourceCount == targetCount {
            return audioLevels
        }

        var result = [CGFloat]()
        result.reserveCapacity(targetCount)

        if sourceCount > targetCount {
            // More audio levels than dots: average levels in each bucket
            let bucketSize = CGFloat(sourceCount) / CGFloat(targetCount)
            for i in 0..<targetCount {
                let startIndex = Int(CGFloat(i) * bucketSize)
                let endIndex = Int(CGFloat(i + 1) * bucketSize)
                let bucket = audioLevels[startIndex..<min(endIndex, sourceCount)]
                let average = bucket.reduce(0, +) / CGFloat(bucket.count)
                result.append(average)
            }
        } else {
            // Fewer audio levels than dots: repeat each level multiple times
            let repeatFactor = CGFloat(targetCount) / CGFloat(sourceCount)
            for i in 0..<targetCount {
                let sourceIndex = Int(CGFloat(i) / repeatFactor)
                result.append(audioLevels[min(sourceIndex, sourceCount - 1)])
            }
        }

        return result
    }

    private func dotHeight(for level: CGFloat, at index: Int, total: Int) -> CGFloat {
        var adjustedLevel = level

        // Apply edge fade effect only during recording
        if isRecording {
            let edgeFadeWidth = min(10, total / 4)

            let edgeMultiplier: CGFloat
            if index < edgeFadeWidth {
                edgeMultiplier = CGFloat(index) / CGFloat(edgeFadeWidth)
            } else if index >= total - edgeFadeWidth {
                edgeMultiplier = CGFloat(total - index - 1) / CGFloat(edgeFadeWidth)
            } else {
                edgeMultiplier = 1.0
            }

            // Apply noise gate to filter background noise
            let noiseThreshold: CGFloat = 0.1
            let gatedLevel = level < noiseThreshold ? 0 : (level - noiseThreshold) / (1.0 - noiseThreshold)

            // Amplify to get taller bars while preserving variation
            let amplifiedLevel = min(1.0, pow(gatedLevel, 0.8) * 1.2)

            adjustedLevel = amplifiedLevel * edgeMultiplier
            let height = max(minDotHeight * edgeMultiplier, adjustedLevel * maxHeight)
            return min(height, maxHeight)
        } else {
            // For playback: simple amplification without edge fade
            let amplifiedLevel = min(1.0, pow(level, 0.8) * 1.2)
            let height = max(minDotHeight, amplifiedLevel * maxHeight)
            return min(height, maxHeight)
        }
    }
}

#Preview("Recording") {
    VoiceWaveformView(
        audioLevels: .constant((0..<50).map { _ in CGFloat.random(in: 0...1.0) }),
        isRecording: .constant(true)
    )
    .padding()
}

#Preview("Idle") {
    VoiceWaveformView(
        audioLevels: .constant([]),
        isRecording: .constant(false)
    )
    .padding()
}

#Preview("Playback with progress") {
    VoiceWaveformView(
        audioLevels: .constant((0..<100).map { _ in CGFloat.random(in: 0...1.0) }),
        isRecording: .constant(false),
        progress: 0.4
    )
    .padding()
}
