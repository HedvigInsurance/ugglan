import Foundation
import SwiftUI

struct InvertColorSchemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content.colorScheme(colorScheme == .dark ? .light : .dark)
    }
}

extension View {
    /// sets color scheme to the opposite of what it was previously
    public var invertColorScheme: some View {
        self.modifier(InvertColorSchemeModifier())
    }
}
