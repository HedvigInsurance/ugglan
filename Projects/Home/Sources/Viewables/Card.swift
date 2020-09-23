import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct Card {
    @ReadWriteState var title: String
    @ReadWriteState var body: String
}

extension Card: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.layer.cornerRadius = .defaultCornerRadius

        view.backgroundColor = .brand(.regularCaution)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.edgeInsets = UIEdgeInsets(horizontalInset: 24, verticalInset: 18)
        view.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        contentView.addArrangedSubview(UILabel(value: title, style: TextStyle.brand(.headline(color: .primary)).centerAligned))

        bag += contentView.addArranged(MultilineLabel(value: body, style: TextStyle.brand(.body(color: .secondary)).centerAligned))

        return (view, bag)
    }
}
