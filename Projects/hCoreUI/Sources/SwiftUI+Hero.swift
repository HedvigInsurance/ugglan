import Hero
import Presentation
import SwiftUI

public struct HeroAnimationWrapper<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) var colorScheme
    public func makeUIView(context: Context) -> UIView {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.layer.cornerRadius = 12
        vc.view.clipsToBounds = true
        vc.view.hero.id = "HeroId"
        vc.view.heroModifiers = [.spring(stiffness: 450, damping: 35)]
        return vc.view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        uiView.backgroundColor = hFillColor.opaqueOne.colorFor(.init(.init(colorScheme))!, .base).color.uiColor()
    }
}

extension UIViewController {
    public func enableHero() {
        self.hero.isEnabled = true
        self.hero.modalAnimationType = .fade
    }
}
