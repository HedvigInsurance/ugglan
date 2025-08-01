import Foundation
import GameKit

/// Generates an array of Integers which represent a random set from a guassian distribution
/// - Parameters:
///   - mean: Mean value of the distribution
///   - deviation: Standard deviation from the mean for the distribution
///   - count: Number of values to be generated
/// - Returns: Array of Integers for the values in distribution
public func generateGaussianHeights(
    mean: Float = 20,
    deviation: Float = 6,
    count: Int = 300,
    maxValue: Int = 30
) -> [Int] {
    let distribution = GKGaussianDistribution(
        randomSource: GKRandomSource(),
        mean: mean,
        deviation: deviation
    )
    var numbers: [Int] = []
    for _ in 1 ... count {
        let diceRoll: Int = {
            let nextValue = distribution.nextInt()
            if nextValue < 0 {
                return 0
            } else if nextValue > maxValue {
                return maxValue
            }
            return nextValue
        }()
        numbers.append(diceRoll)
    }

    return numbers
}
