import GameKit
import SwiftUI

public struct WaveformView<StripeColor: hColor>: View {
    private let stripeWidth: CGFloat = 2
    private let stripeSpacing: CGFloat = 3
    private let mean: Float
    private let deviation: Float

    private let stripeColor: StripeColor

    public init(
        mean: Float = 20,
        deviation: Float = 6,
        stripeColor: StripeColor
    ) {
        self.mean = mean
        self.deviation = deviation
        self.stripeColor = stripeColor
    }

    private var maxStripeHeight: CGFloat {
        // The possible range of values in a guassian distribution is
        // mean - 3*deviation   to   mean + 3*deviation
        CGFloat(mean + 3 * deviation)
    }

    private func getHeights(count: Int = 60) -> [Int] {
        let random = GKRandomSource()
        let dist = GKGaussianDistribution(
            randomSource: random,
            mean: mean,
            deviation: deviation
        )
        var numbers: [Int] = []

        for _ in 1...count {
            let diceRoll = dist.nextInt()
            numbers.append(diceRoll)
        }
        return numbers
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
        let heights = getHeights(count: Int(count))

        return HStack(spacing: stripeSpacing) {
            ForEach(heights, id: \.self) { height in
                RoundedRectangle(cornerRadius: stripeWidth / 2)
                    .fill(self.stripeColor)
                    .frame(width: stripeWidth, height: abs(CGFloat(height)))
            }
        }
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(
            stripeColor: hLabelColor.link
        )
    }
}
