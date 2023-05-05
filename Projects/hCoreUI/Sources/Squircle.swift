import Foundation
import SwiftUI

public struct Squircle: Shape {
    var radius: CGFloat
    var smooth: CGFloat
    var lineWidth: CGFloat

    func normalisedRadius(in rect: CGRect) -> CGFloat {
        min(
            radius,
            min(rect.height / 2, rect.height / 2)
        )
    }

    public func path(in rect: CGRect) -> Path {
        Path { path in
            let normalisedRadius = self.normalisedRadius(in: rect)

            let lineWidthOffset = lineWidth / 2
            path.move(to: CGPoint(x: normalisedRadius, y: lineWidthOffset))

            path.addLine(to: CGPoint(x: rect.width - normalisedRadius, y: lineWidthOffset))
            path.addCurve(
                to: CGPoint(x: rect.width - lineWidthOffset, y: normalisedRadius),
                control1: CGPoint(x: rect.width - normalisedRadius / smooth, y: lineWidthOffset),
                control2: CGPoint(x: rect.width - lineWidthOffset, y: normalisedRadius / smooth)
            )

            path.addLine(to: CGPoint(x: rect.width - lineWidthOffset, y: rect.height - normalisedRadius))
            path.addCurve(
                to: CGPoint(x: rect.width - normalisedRadius, y: rect.height - lineWidthOffset),
                control1: CGPoint(x: rect.width - lineWidthOffset, y: rect.height - normalisedRadius / smooth),
                control2: CGPoint(x: rect.width - normalisedRadius / smooth, y: rect.height - lineWidthOffset)
            )

            path.addLine(to: CGPoint(x: normalisedRadius, y: rect.height - lineWidthOffset))
            path.addCurve(
                to: CGPoint(x: lineWidthOffset, y: rect.height - normalisedRadius),
                control1: CGPoint(x: normalisedRadius / smooth, y: rect.height - lineWidthOffset),
                control2: CGPoint(x: lineWidthOffset, y: rect.height - normalisedRadius / smooth)
            )

            path.addLine(to: CGPoint(x: lineWidthOffset, y: normalisedRadius))
            path.addCurve(
                to: CGPoint(x: normalisedRadius, y: lineWidthOffset),
                control1: CGPoint(x: lineWidthOffset, y: normalisedRadius / smooth),
                control2: CGPoint(x: normalisedRadius / smooth, y: lineWidthOffset)
            )

            path.closeSubpath()
        }
    }

    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(radius, smooth) }
        set {
            self.radius = newValue.first
            self.smooth = newValue.second
        }
    }
}
