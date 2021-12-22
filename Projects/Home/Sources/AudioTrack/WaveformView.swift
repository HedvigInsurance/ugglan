import GameKit
import SwiftUI
import hCoreUI

struct WaveformView: View {
    private let stripeWidth: CGFloat = 2
    private let stripeSpacing: CGFloat = 3
    private let mean: Float = 20
    private let deviation: Float = 6

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

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { geometry in
                self.makeView(geometry)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: maxStripeHeight)
    }

    func makeView(_ geometry: GeometryProxy) -> some View {
        // Get the number of stripes by dividing width with individual stripe width
        // Individual stripe width = stripeWidth + stripeSpacing
        let count = geometry.size.width / (stripeWidth + stripeSpacing)
        let heights = getHeights(count: Int(count))

        return HStack(spacing: stripeSpacing) {
            ForEach(heights, id: \.self) { height in
                RoundedRectangle(cornerRadius: stripeWidth / 2)
                    .fill(hLabelColor.link)
                    .frame(width: stripeWidth, height: abs(CGFloat(height)))
            }
        }
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView()
    }
}
