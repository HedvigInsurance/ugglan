import SwiftUI

public struct PillowShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        // The source path spans 0...302.785 in both axes.
        let extent: CGFloat = 302.785

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + x / extent * rect.width,
                y: rect.minY + y / extent * rect.height
            )
        }

        var path = Path()
        path.move(to: point(0, 151.392))
        path.addCurve(
            to: point(151.58, 302.785),
            control1: point(0, 259.796),
            control2: point(47.6025, 302.785)
        )
        path.addCurve(
            to: point(302.785, 151.392),
            control1: point(255.558, 302.785),
            control2: point(302.785, 261.701)
        )
        path.addCurve(
            to: point(151.58, 0),
            control1: point(302.785, 41.0842),
            control2: point(255.558, 0)
        )
        path.addCurve(
            to: point(0, 151.392),
            control1: point(47.6025, 0),
            control2: point(0, 42.9893)
        )
        path.closeSubpath()
        return path
    }
}
