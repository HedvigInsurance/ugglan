import Combine
import Foundation
import SwiftUI

struct ExpandAppearAnimationModifier: ViewModifier {
    @State var hasAppeared = false
    func body(content: Content) -> some View {
        content
            .frame(maxHeight: hasAppeared ? .infinity : 0)
            .opacity(hasAppeared ? 1 : 0)
            .clipped()
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 100).delay(0.15)) {
                    hasAppeared = true
                }
            }
    }
}

extension View {
    public func expandAppearAnimation() -> some View {
        self.modifier(ExpandAppearAnimationModifier())
    }
}
