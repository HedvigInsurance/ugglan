import Hero
import Presentation
import SwiftUI

public struct HeroAnimationStartView: UIViewRepresentable {
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.hero.id = "heroId"
        view.layer.cornerRadius = 12
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        let schema = UITraitCollection.current.userInterfaceStyle
        uiView.backgroundColor = hFillColor.opaqueOne.colorFor(.init(schema)!, .base).color.uiColor()
    }
}

public struct HeroAnimationDestinationView<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.hero.id = "heroId"
        view.heroModifiers = [.spring(stiffness: 250, damping: 25)]
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
        let schema = UITraitCollection.current.userInterfaceStyle
        uiView.backgroundColor = hFillColor.opaqueOne.colorFor(.init(schema)!, .base).color.uiColor()
    }
}

extension JourneyPresentation {
    public var enableHero: Self {
        addConfiguration { presenter in
            presenter.viewController.hero.isEnabled = true
        }
    }
}
