import Hero
import Presentation
import SwiftUI

public struct HeroAnimationStartView<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) var colorScheme
    public func makeUIView(context: Context) -> UIView {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.hero.id = "mainHeroId"
        vc.view.heroModifiers = [.spring(stiffness: 250, damping: 25), .fade]
        vc.view.layer.cornerRadius = 12
        return vc.view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        uiView.backgroundColor = hFillColor.opaqueOne.colorFor(.init(.init(colorScheme))!, .base).color.uiColor()
    }
}

public struct HeroAnimationDestinationView<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) var colorScheme
    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.hero.id = "mainHeroId"
        //        view.heroModifiers = [.spring(stiffness: 250, damping: 25), .fade]
        view.layer.cornerRadius = 12
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        view.addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        uiView.backgroundColor = hBackgroundColor.primary.colorFor(.init(.init(colorScheme))!, .base).color.uiColor()
    }
}

extension JourneyPresentation {
    public var enableHero: Self {
        addConfiguration { presenter in
            presenter.viewController.hero.isEnabled = true
        }
    }
}
