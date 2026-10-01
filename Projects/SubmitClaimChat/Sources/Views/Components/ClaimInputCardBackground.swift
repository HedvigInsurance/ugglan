import SwiftUI
import hCoreUI

struct ClaimInputCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusXXXL)
                    .fill(hFillColor.Opaque.negative)
            )
            .hCardShadow()
    }
}

extension View {
    func claimInputCardBackground() -> some View {
        modifier(ClaimInputCardBackground())
    }
}
