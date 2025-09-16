import SwiftUI

extension View {
    public func dismissKeyboard() -> some View {
        if #available(iOS 16, *) {
            return self.modifier(DismissKeyboardModifier())
        } else {
            return self
        }
    }
}

@available(iOS 16, *)
struct DismissKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
    }
}
