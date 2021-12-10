import Foundation
import Hero
import SwiftUI

struct HeroViewContainer<Content: View>: View, UIViewRepresentable {
    let id: String
    let isHeroEnabled: Bool
    let modifiers: [HeroModifier]
    let content: Content

    class Coordinator {
        internal init(
            hostingView: HostingView<AnyView>
        ) {
            self.hostingView = hostingView
        }

        func updateRootView(_ content: AnyView) {
            self.hostingView.swiftUIRootView = content
        }

        var hostingView: HostingView<AnyView>
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(hostingView: HostingView(rootView: AnyView(EmptyView())))
    }

    func makeUIView(context: Context) -> some UIView {
        let view = context.coordinator.hostingView
        context.coordinator.updateRootView(
            AnyView(content.modifier(TransferEnvironment(environment: context.environment)))
        )
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.hero.isEnabled = true
        uiView.hero.id = isHeroEnabled ? id : nil
        uiView.hero.modifiers = modifiers
        context.coordinator.updateRootView(
            AnyView(content.modifier(TransferEnvironment(environment: context.environment)))
        )
    }
}

extension View {
    public func enableHero(_ id: String, modifiers: [HeroModifier] = []) -> some View {
        HeroViewContainer(id: id, isHeroEnabled: true, modifiers: modifiers, content: self)
    }
}
