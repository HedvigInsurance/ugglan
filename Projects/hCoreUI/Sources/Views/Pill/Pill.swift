import Flow
import Form
import Foundation
import UIKit
import hCore

public struct Pill: Hashable, ReusableSizeable {
    public init(
        style: Style,
        title: DisplayableString,
        textStyle: TextStyle = .brand(.caption1(color: .secondary(state: .positive)))
    ) {
        self.style = style
        self.title = title
        self.textStyle = textStyle
    }

    public enum Style {
        case effected
        case solid(color: UIColor)
    }

    public static func == (lhs: Pill, rhs: Pill) -> Bool { lhs.hashValue == rhs.hashValue }

    @ReadWriteState public var title: DisplayableString
    public let style: Style
    public let textStyle: TextStyle
    public let id = UUID()

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Pill: Reusable {
    public static func makeAndConfigure() -> (make: UIView, configure: (Pill) -> Disposable) {
        let pillView = UIView()
        pillView.layer.cornerRadius = 4

        return (
            pillView,
            { `self` in let bag = DisposeBag()

                switch self.style {
                case .effected: pillView.embed()
                case let .solid(color: color): pillView.backgroundColor = color
                }

                let label = UILabel(value: self.title, style: self.textStyle)
                pillView.addSubview(label)

                bag += { label.removeFromSuperview() }

                bag += self.$title.bindTo(label)

                let horizontalInset: CGFloat = 6
                let verticalInset: CGFloat = 4

                label.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(horizontalInset)
                    make.top.bottom.equalToSuperview().inset(verticalInset)
                }

                bag += label.didLayoutSignal.onValue { _ in
                    pillView.snp.makeConstraints { make in
                        make.width.equalTo(
                            label.intrinsicContentSize.width + (horizontalInset * 2)
                        )
                    }
                }

                return bag
            }
        )
    }
}

extension UIView {
    fileprivate func embed() {
        let effect: UIBlurEffect

        if #available(iOS 13.0, *) {
            effect = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            effect = UIBlurEffect(style: .light)
        }

        let pillView = UIVisualEffectView(effect: effect)
        pillView.layer.cornerRadius = 4
        pillView.layer.masksToBounds = true
        addSubview(pillView)

        pillView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

        let vibrancyView: UIVisualEffectView

        if #available(iOS 13.0, *) {
            vibrancyView = UIVisualEffectView(
                effect: UIVibrancyEffect(blurEffect: effect, style: .secondaryLabel)
            )
        } else {
            vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect))
        }

        pillView.contentView.addSubview(vibrancyView)

        vibrancyView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }
    }
}
