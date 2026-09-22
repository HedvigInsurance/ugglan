import SwiftUI

public struct WaveformView<StripeColor: hColor>: View {
    private let stripeWidth: CGFloat = 2
    private let stripeSpacing: CGFloat = 3
    private let maxStripeHeight: CGFloat
    private let stripeColor: StripeColor
    private let sampleHeights: [Int]
    private let progress: Double
    private let progressColor: (any hColor)?

    public init(
        maxStripeHeight: CGFloat = 30,
        stripeColor: StripeColor,
        sampleHeights: [Int]
    ) {
        self.maxStripeHeight = maxStripeHeight
        self.stripeColor = stripeColor
        self.sampleHeights = sampleHeights
        self.progress = 0
        self.progressColor = nil
    }

    public init(
        maxStripeHeight: CGFloat = 30,
        stripeColor: StripeColor,
        sampleHeights: [Int],
        progress: Double,
        progressColor: any hColor
    ) {
        self.maxStripeHeight = maxStripeHeight
        self.stripeColor = stripeColor
        self.sampleHeights = sampleHeights
        self.progress = progress
        self.progressColor = progressColor
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            WaveformShape(
                sampleHeights: sampleHeights,
                stripeWidth: stripeWidth,
                stripeSpacing: stripeSpacing,
                fraction: 1
            )
            .fill(stripeColor)

            if let progressColor, progress > 0 {
                WaveformShape(
                    sampleHeights: sampleHeights,
                    stripeWidth: stripeWidth,
                    stripeSpacing: stripeSpacing,
                    fraction: progress
                )
                .fill(progressColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: maxStripeHeight)
    }
}

private struct WaveformShape: Shape {
    let sampleHeights: [Int]
    let stripeWidth: CGFloat
    let stripeSpacing: CGFloat
    var fraction: Double

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let pitch = stripeWidth + stripeSpacing
        guard !sampleHeights.isEmpty, rect.width > 0, rect.height > 0, pitch > 0 else { return path }

        let count = min(Int(rect.width / pitch), sampleHeights.count)
        let limit = rect.width * CGFloat(min(max(fraction, 0), 1))
        let cornerSize = CGSize(width: stripeWidth / 2, height: stripeWidth / 2)

        for index in 0..<count {
            let x = CGFloat(index) * pitch
            if x > limit { break }
            let height = min(abs(CGFloat(sampleHeights[index])), rect.height)
            path.addRoundedRect(
                in: CGRect(x: x, y: (rect.height - height) / 2, width: stripeWidth, height: height),
                cornerSize: cornerSize
            )
        }
        return path
    }
}
