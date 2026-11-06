import CrossSellCore
import SwiftUI

extension View {
    /// Runs `action` once at least half of this view has been visible for half a second, measured against the
    /// nearest enclosing scroll view, and again whenever that happens anew. Dedupe with a `CrossSellShownTracker`.
    public func onCrossSellShown(perform action: @escaping @MainActor () -> Void) -> some View {
        modifier(CrossSellShownModifier(action: action))
    }
}

private struct CrossSellShownModifier: ViewModifier {
    let action: @MainActor () -> Void
    @State private var isHalfVisible = false

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: Bool.self, of: \.isHalfVisible) { isHalfVisible = $0 }
            .task(id: isHalfVisible) {
                guard isHalfVisible else { return }
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                action()
            }
    }
}

extension GeometryProxy {
    fileprivate var isHalfVisible: Bool {
        let bounds = CGRect(origin: .zero, size: size)
        guard bounds.width > 0, bounds.height > 0 else { return false }
        // Outside a scroll view nothing can move the view off screen.
        guard let viewport = self.bounds(of: .scrollView) else { return true }
        let visible = bounds.intersection(viewport)
        guard !visible.isNull else { return false }
        return visible.width * visible.height >= bounds.width * bounds.height / 2
    }
}
