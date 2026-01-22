import SwiftUI
import hCoreUI

public struct FixedDotsWaveformView: View {
    let audioLevels: [CGFloat]
    let maxHeight: CGFloat
    let progress: Double?

    private let dotSize: CGFloat = 2
    private let dotSpacing: CGFloat = 2
    private let minDotHeight: CGFloat = 2

    public init(
        audioLevels: [CGFloat],
        maxHeight: CGFloat = 60,
        progress: Double? = nil
    ) {
        self.audioLevels = audioLevels
        self.maxHeight = maxHeight
        self.progress = progress
    }

    public var body: some View {
        GeometryReader { geometry in
            let dotCount = calculateDotCount(for: geometry.size.width)
            let levels = resampleLevels(to: dotCount)

            let waveform = HStack(spacing: dotSpacing) {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                    RoundedRectangle(cornerRadius: dotSize / 2)
                        .fill(hTextColor.Opaque.primary)
                        .frame(
                            width: dotSize,
                            height: dotHeight(for: level)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if let progress = progress {
                waveform
                    .overlay(
                        GeometryReader { geo in
                            Rectangle()
                                .fill(hFillColor.Opaque.tertiary)
                                .frame(width: geo.size.width * progress)
                        }
                        .mask(waveform)
                    )
            } else {
                waveform
            }
        }
        .frame(height: maxHeight)
    }

    private func calculateDotCount(for width: CGFloat) -> Int {
        max(1, Int(width / (dotSize + dotSpacing)))
    }

    private func resampleLevels(to targetCount: Int) -> [CGFloat] {
        guard !audioLevels.isEmpty else {
            return Array(repeating: 0, count: targetCount)
        }

        let sourceCount = audioLevels.count

        if sourceCount == targetCount {
            return audioLevels
        }

        var result = [CGFloat]()
        result.reserveCapacity(targetCount)

        if sourceCount > targetCount {
            // More audio levels than dots: average levels in each bucket
            // e.g., 1000 levels, 100 dots -> average every 10 levels per dot
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
            // e.g., 10 levels, 100 dots -> show each level 10 times
            let repeatFactor = CGFloat(targetCount) / CGFloat(sourceCount)
            for i in 0..<targetCount {
                let sourceIndex = Int(CGFloat(i) / repeatFactor)
                result.append(audioLevels[min(sourceIndex, sourceCount - 1)])
            }
        }

        return result
    }

    private func dotHeight(for level: CGFloat) -> CGFloat {
        let amplifiedLevel = min(1.0, pow(level, 0.65) * 2.5)
        let height = max(minDotHeight, amplifiedLevel * maxHeight)
        return min(height, maxHeight)
    }
}

#Preview("FixedDots - Many levels") {
    // 200 audio levels will be downsampled to fit available dots
    FixedDotsWaveformView(
        audioLevels: (0..<200).map { _ in CGFloat.random(in: 0...1.0) }
    )
    .padding()
}

#Preview("FixedDots - Few levels") {
    // 10 audio levels will be repeated to fill available dots
    FixedDotsWaveformView(
        audioLevels: (0..<10).map { _ in CGFloat.random(in: 0...1.0) }
    )
    .padding()
}

#Preview("FixedDots - With progress") {
    FixedDotsWaveformView(
        audioLevels: (0..<100).map { _ in CGFloat.random(in: 0...1.0) },
        progress: 0.4
    )
    .padding()
}
