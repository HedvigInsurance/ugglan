import Flow
import hCore
import UIKit

public struct Bullet {
    @ReadWriteState public var isSelected = false

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public init(isSelectedSignal: ReadWriteSignal<Bool>) {
        _isSelected = .init(wrappedValue: isSelectedSignal)
    }
}

extension Bullet: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIControl, Disposable) {
        let bag = DisposeBag()

        let control = UIControl()
        control.layer.borderWidth = 1
        control.clipsToBounds = true
        control.backgroundColor = .clear

        let largeCircle = UIView()
        largeCircle.backgroundColor = .clear
        largeCircle.isHidden = true
        largeCircle.layer.borderWidth = 8

        control.snp.makeConstraints {
            $0.height.width.equalTo(24)
        }

        control.addSubview(largeCircle)

        largeCircle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bag += control.applyBorderColor { _ in
            .brand(.primaryBorderColor)
        }

        bag += largeCircle.applyBorderColor { _ in
            .brand(.primaryBackground(true))
        }

        bag += control.didLayoutSignal.onValue {
            control.layer.cornerRadius = control.bounds.width / 2
            largeCircle.layer.cornerRadius = largeCircle.bounds.width / 2
        }

        bag += $isSelected.atOnce().withLatestFrom(control.traitCollectionSignal).animated(style: SpringAnimationStyle.lightBounce(), animations: { isSelected, _ in
            largeCircle.isHidden = !isSelected
        })

        return (control, bag)
    }
}
