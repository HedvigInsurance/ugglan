import Hero
import SwiftUI

public struct HeroAnimationWrapper<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) var colorScheme
    private let id: String
    private let cornerRadius: CGFloat
    public init(id: String, cornerRadius: CGFloat = .cornerRadiusL, content: @escaping () -> Content) {
        self.content = content
        self.id = id
        self.cornerRadius = cornerRadius
    }

    public func makeUIView(context: Context) -> UIView {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.layer.cornerRadius = cornerRadius
        vc.view.clipsToBounds = true
        vc.view.hero.id = id
        vc.view.heroModifiers = [.spring(stiffness: 450, damping: 35)]
        return vc.view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        uiView.backgroundColor = hSurfaceColor.Opaque.primary.colorFor(.init(.init(colorScheme))!, .base).color
            .uiColor()
    }
}

extension UIViewController {
    public func enableHero() {
        self.hero.isEnabled = true
        self.hero.modalAnimationType = .fade
    }
}
