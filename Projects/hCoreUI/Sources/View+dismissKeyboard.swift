import SwiftUI

extension View {
    public func dismissKeyboard() -> some View {
        self.modifier(DismissKeyboardModifier())
    }
}

struct DismissKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .scrollDismissesKeyboard(.interactively)
        } else {
            content
                .scrollDismissesKeyboard(.immediately)
        }
    }
}
