import SwiftUI

extension View {
    public func wrapWithBorder() -> some View {
        modifier(WrapInBorder())
    }
}

private struct WrapInBorder: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusXL)
                    .inset(by: 0.5)
                    .stroke(hBorderColor.primary, lineWidth: 1)
            )
    }
}
