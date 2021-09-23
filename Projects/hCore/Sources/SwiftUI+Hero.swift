import Foundation
import Hero
import SwiftUI

struct HeroViewContainer<Content: View>: View, UIViewRepresentable {
    let id: String
    let isHeroEnabled: Bool
    let modifiers: [HeroModifier]
    let content: Content

    func makeUIView(context: Context) -> some UIView {
        let view = HostingView(rootView: content.modifier(TransferEnvironment(environment: context.environment)))
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.hero.isEnabled = true
        uiView.hero.id = isHeroEnabled ? id : nil
        uiView.hero.modifiers = modifiers
    }
}

extension View {
    public func enableHero(_ id: String, modifiers: [HeroModifier] = []) -> some View {
        HeroViewContainer(id: id, isHeroEnabled: true, modifiers: modifiers, content: self)
    }
}
