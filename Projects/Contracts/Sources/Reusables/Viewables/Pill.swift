import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct Pill {
    @ReadWriteState var title: DisplayableString
    let backgroundColor: UIColor
}

extension Pill: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let pillView = UIView()
        pillView.layer.cornerRadius = 4
        pillView.backgroundColor = backgroundColor

        let label = UILabel(value: title, style: .brand(.caption1(color: .secondary)))
        pillView.addSubview(label)

        bag += $title.bindTo(label)

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

        return (pillView, bag)
    }
}
