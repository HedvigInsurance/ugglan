import Foundation
import hCore
import hCoreUI
import SwiftUI

struct Slice: Shape {
    var startSlices: CGFloat = 0
    var percentage: CGFloat
    var percentagePerSlice: CGFloat
    var slices: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            let width: CGFloat = min(rect.size.width, rect.size.height)
            let height = width

            let center = CGPoint(x: width * 0.5, y: height * 0.5)

            path.move(to: center)

            path.addArc(
                center: center,
                radius: width * 0.5,
                startAngle: Angle(degrees: -90.0) + Angle(degrees: percentagePerSlice * startSlices * 360.0),
                endAngle: Angle(degrees: -90.0)
                    + Angle(
                        degrees: 360 * percentagePerSlice
                            * (max((slices - startSlices) * percentage, 0.0001) + startSlices)
                    ),
                clockwise: false
            )
        }
    }

    var animatableData: Double {
        get { percentage }
        set { percentage = newValue }
    }
}
