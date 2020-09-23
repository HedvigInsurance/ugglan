import Flow
import Form
import Foundation
import hCore
import UIKit

public struct PagerDots {
    public let pageIndexSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
    public let pageAmountSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)

    public init() {}
}

extension PagerDots: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10

        view.addSubview(stackView)

        bag += view.didLayoutSignal.onValue {
            stackView.snp.makeConstraints { make in
                make.height.centerX.centerY.equalToSuperview()
            }
        }

        func dotColor(active: Bool) -> UIColor {
            if active {
                return UIColor(dynamic: { trait in
                    if trait.userInterfaceStyle == .dark {
                        return .white
                    }

                    return .black
                })
            }

            return .gray
        }

        bag += pageAmountSignal.atOnce().filter { $0 != 0 }.onValue { pageAmount in
            for subview in stackView.subviews {
                subview.removeFromSuperview()
            }

            for i in 0 ... pageAmount - 1 {
                let indicator = UIView()
                indicator.backgroundColor = dotColor(active: i == 0)
                indicator.transform = i == 0 ? CGAffineTransform(scaleX: 1.5, y: 1.5) : CGAffineTransform.identity
                indicator.layer.cornerRadius = 2

                indicator.snp.makeConstraints { make in
                    make.width.height.equalTo(4)
                }

                stackView.addArrangedSubview(indicator)
            }
        }

        bag += pageIndexSignal.animated(style: SpringAnimationStyle.heavyBounce()) { pageIndex in
            for (index, indicator) in stackView.subviews.enumerated() {
                let indicatorIsActive = index == pageIndex

                indicator.backgroundColor = dotColor(active: indicatorIsActive)
                indicator.transform = indicatorIsActive ? CGAffineTransform(scaleX: 1.5, y: 1.5) : CGAffineTransform.identity
            }
        }

        return (view, bag)
    }
}
