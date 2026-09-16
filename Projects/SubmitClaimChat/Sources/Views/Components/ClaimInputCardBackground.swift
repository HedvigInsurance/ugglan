import SwiftUI
import hCoreUI

/// Card container shared by the text and voice inputs (Figma "Menu - iPhone": radius 32, soft shadow).
struct ClaimInputCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusXXXL)
                    .fill(hFillColor.Opaque.negative)
            )
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
    }
}

extension View {
    /// Draws the view as a floating input card docked at the bottom of the claim chat.
    func claimInputCardBackground() -> some View {
        modifier(ClaimInputCardBackground())
    }
}
