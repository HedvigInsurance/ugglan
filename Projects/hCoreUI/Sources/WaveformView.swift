import GameKit
import SwiftUI

public struct WaveformView<StripeColor: hColor>: View {
    private let stripeWidth: CGFloat = 2
    private let stripeSpacing: CGFloat = 3
    private let maxStripeHeight: CGFloat
    private let stripeColor: StripeColor
    private let sampleHeights: [Int]

    public init(
        maxStripeHeight: CGFloat = 40,
        stripeColor: StripeColor,
        sampleHeights: [Int]
    ) {
        self.maxStripeHeight = maxStripeHeight
        self.stripeColor = stripeColor
        self.sampleHeights = sampleHeights
    }

    public var body: some View {
        VStack(alignment: .center) {
            GeometryReader { geometry in
                self.makeView(geometry)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: maxStripeHeight)
    }

    private func makeView(_ geometry: GeometryProxy) -> some View {
        // Get the number of stripes by dividing width with individual stripe width
        // Individual stripe width = stripeWidth + stripeSpacing
        let count = geometry.size.width / (stripeWidth + stripeSpacing)
        let heights = sampleHeights.prefix(Int(count))

        return HStack(spacing: stripeSpacing) {
            ForEach(heights, id: \.self) { height in
                RoundedRectangle(cornerRadius: stripeWidth / 2)
                    .fill(self.stripeColor)
                    .frame(width: stripeWidth, height: abs(CGFloat(height)))
            }
        }
    }
}
