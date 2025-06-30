import SwiftUI

public struct hRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    public init(cornerRadius: CGFloat, corners: UIRectCorner) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}
