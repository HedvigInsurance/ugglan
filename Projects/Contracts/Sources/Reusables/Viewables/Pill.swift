import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct Pill: Hashable {
    static func == (lhs: Pill, rhs: Pill) -> Bool {
        lhs.title.displayValue == rhs.title.displayValue && lhs.backgroundColor == rhs.backgroundColor
    }

    @ReadWriteState var title: DisplayableString
    let backgroundColor: UIColor

    func hash(into hasher: inout Hasher) {
        hasher.combine(title.displayValue)
        hasher.combine(backgroundColor)
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
        let pillView = UIView()
        pillView.layer.cornerRadius = 4

        return (pillView, { `self` in
            let bag = DisposeBag()

            pillView.backgroundColor = self.backgroundColor

            let label = UILabel(value: self.title, style: .brand(.caption1(color: .secondary)))
            pillView.addSubview(label)

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
