import Flow
import Form
import Foundation
import hCoreUI
import Presentation
import UIKit

struct PerilDetail {
    let title: String
    let description: String
    let icon: RemoteVectorIcon
}

extension PerilDetail: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 24)

        form.append(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        let icon = self.icon

        bag += stackView.addArranged(icon) { iconView in
            iconView.snp.makeConstraints { make in
                make.height.width.equalTo(80)
            }
        }

        bag += stackView.addArranged(Spacing(height: 20))

        stackView.addArrangedSubview(UILabel(
            value: title,
            style: .brand(.title1(color: .primary))
        ))

        bag += stackView.addArranged(Spacing(height: 15))

        bag += stackView.addArranged(MultilineLabel(
            value: description,
            style: TextStyle.brand(.body(color: .primary)).centerAligned
        ))

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
