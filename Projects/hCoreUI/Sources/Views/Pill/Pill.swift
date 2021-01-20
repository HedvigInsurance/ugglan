import Flow
import Form
import Foundation
import hCore
import UIKit

public struct Pill: Hashable, ReusableSizeable {
    public init(
        tintColor: UIColor,
        title: DisplayableString,
        textStyle: TextStyle = .brand(.caption1(color: .secondary(state: .positive)))
    ) {
        self.tintColor = tintColor
        self.title = title
        self.textStyle = textStyle
    }
    
    public static func == (lhs: Pill, rhs: Pill) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    @ReadWriteState public var title: DisplayableString
    public let tintColor: UIColor
    public let textStyle: TextStyle

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title.displayValue)
        hasher.combine(tintColor)
    }
}

extension Pill: Reusable {
    public static func makeAndConfigure() -> (make: UIView, configure: (Pill) -> Disposable) {
        let pillView = UIView()
        pillView.layer.cornerRadius = 4

        return (pillView, { `self` in
            let bag = DisposeBag()

            pillView.backgroundColor = self.tintColor

            let label = UILabel(value: self.title, style: self.textStyle)
            pillView.addSubview(label)

            bag += {
                label.removeFromSuperview()
            }

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
