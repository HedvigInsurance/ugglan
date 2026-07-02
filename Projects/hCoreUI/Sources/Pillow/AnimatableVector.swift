import SwiftUI

struct AnimatableVector: VectorArithmetic {
    var values: [Double]

    init(_ values: [Double] = []) { self.values = values }

    static var zero: AnimatableVector { AnimatableVector([]) }

    static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        AnimatableVector(elementwise(lhs.values, rhs.values, +))
    }

    static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        AnimatableVector(elementwise(lhs.values, rhs.values, -))
    }

    mutating func scale(by rhs: Double) {
        values = values.map { $0 * rhs }
    }

    var magnitudeSquared: Double {
        values.reduce(0) { $0 + $1 * $1 }
    }

    private static func elementwise(
        _ a: [Double],
        _ b: [Double],
        _ op: (Double, Double) -> Double
    ) -> [Double] {
        let n = Swift.max(a.count, b.count)
        return (0..<n)
            .map { i in
                op(i < a.count ? a[i] : 0, i < b.count ? b[i] : 0)
            }
    }
}


extension PillowConfiguration {
    /// The scalar parameters, in a fixed order, that precede the color/point data.
    private var scalarValues: [Double] {
        [
            waveX, waveY, waveXShift, waveYShift,
            mixing, grainMixer, grainOverlay, highlightGrain, contrast,
            scale, rotation, offsetX, offsetY,
        ]
    }

    private static let scalarCount = 13

    /// Flattened representation used as `animatableData`. Layout:
    /// `[12 scalars][rgba per color][xy per point]`.
    var animatableVector: AnimatableVector {
        var out = scalarValues
        for color in colors {
            let c = color.pillowRGBA
            out.append(contentsOf: [Double(c.0), Double(c.1), Double(c.2), Double(c.3)])
        }
        let points = pointComponents()
        out.append(contentsOf: points.map(Double.init))
        return AnimatableVector(out)
    }

    /// Rebuilds interpolated fields from a vector produced by ``animatableVector``.
    /// `colors.count` is preserved from the current value (SwiftUI sets the view
    /// to the target config before animating, so the count is already correct).
    mutating func apply(_ vector: AnimatableVector) {
        let v = vector.values
        guard v.count >= PillowConfiguration.scalarCount else { return }

        waveX = v[0]; waveY = v[1]; waveXShift = v[2]; waveYShift = v[3]
        mixing = v[4]; grainMixer = v[5]; grainOverlay = v[6]; highlightGrain = v[7]
        contrast = v[8]
        scale = v[9]; rotation = v[10]; offsetX = v[11]; offsetY = v[12]

        let n = colors.count
        var idx = PillowConfiguration.scalarCount

        var newColors: [Color] = []
        newColors.reserveCapacity(n)
        for _ in 0..<n {
            guard idx + 3 < v.count else { break }
            newColors.append(
                Color(.sRGB, red: v[idx], green: v[idx + 1], blue: v[idx + 2], opacity: v[idx + 3])
            )
            idx += 4
        }
        if newColors.count == n { colors = newColors }

        var newPoints: [CGPoint] = []
        newPoints.reserveCapacity(n)
        for _ in 0..<n {
            guard idx + 1 < v.count else { break }
            newPoints.append(CGPoint(x: v[idx], y: v[idx + 1]))
            idx += 2
        }
        if newPoints.count == n { meshPoints = newPoints }
    }
}
