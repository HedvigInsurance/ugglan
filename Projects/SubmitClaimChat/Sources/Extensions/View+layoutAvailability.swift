import SwiftUI

extension View {
    /// Animates the view's children as one unit when it transitions in or out (iOS 17+); a no-op before that.
    /// Used by the docked input cards so their contents don't animate ahead of the card.
    @ViewBuilder
    func geometryGroupIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            geometryGroup()
        } else {
            self
        }
    }
}

extension View {
    /// Lets a scroll view's content draw outside its bounds (iOS 17+); a no-op before that.
    @ViewBuilder
    func scrollClipDisabledIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            scrollClipDisabled()
        } else {
            self
        }
    }
}
