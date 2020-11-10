import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct Pill: Hashable {
    static func == (lhs: Pill, rhs: Pill) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    @ReadWriteState var title: DisplayableString
    let tintColor: UIColor?

    func hash(into hasher: inout Hasher) {
        hasher.combine(title.displayValue)
        hasher.combine(tintColor)
    }

    var size: CGSize {
        let (view, configure) = Self.makeAndConfigure()

        let bag = DisposeBag()
        bag += configure(self)

        let size = view.systemLayoutSizeFitting(.zero)

        bag.dispose()

        return size
    }
}

extension Pill: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (Pill) -> Disposable) {
        let containerView = UIView()

        let effect: UIBlurEffect

        if #available(iOS 13.0, *) {
            effect = UIBlurEffect(style: .systemThinMaterial)
        } else {
            effect = UIBlurEffect(style: .light)
        }

        let pillView = UIVisualEffectView(effect: effect)
        pillView.layer.cornerRadius = 4
        pillView.layer.masksToBounds = true
        containerView.addSubview(pillView)

        pillView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let tintView = UIView()
        tintView.layer.cornerRadius = 4
        containerView.addSubview(tintView)

        tintView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let vibrancyView: UIVisualEffectView

        if #available(iOS 13.0, *) {
            vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect, style: .secondaryLabel))
        } else {
            vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect))
        }

        pillView.contentView.addSubview(vibrancyView)

        vibrancyView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        return (containerView, { `self` in
            let bag = DisposeBag()

            tintView.backgroundColor = self.tintColor?.withAlphaComponent(0.1)

            let label = UILabel(value: self.title, style: .brand(.caption1(color: .secondary)))
            vibrancyView.contentView.addSubview(label)

            bag += self.$title.bindTo(label)

            let horizontalInset: CGFloat = 6
            let verticalInset: CGFloat = 4

            label.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(horizontalInset)
                make.top.bottom.equalToSuperview().inset(verticalInset)
            }

            bag += label.didLayoutSignal.onValue { _ in
                pillView.snp.makeConstraints { make in
                    make.width.equalTo(label.intrinsicContentSize.width + (horizontalInset * 2))
                }
            }

            return bag
        })
    }
}
