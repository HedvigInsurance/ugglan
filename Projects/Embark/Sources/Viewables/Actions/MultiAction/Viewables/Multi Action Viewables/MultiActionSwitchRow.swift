import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct MultiActionSwitchRow {
    let data: EmbarkSwitchActionData
}

extension MultiActionSwitchRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
        let bag = DisposeBag()

        let containerView = UIView()
        bag += containerView.traitCollectionSignal.onValue { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                containerView.backgroundColor = .grayscale(.grayFive)
            default:
                containerView.backgroundColor = .brand(.primaryBackground())
            }
        }

        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 10
        view.edgeInsets = .init(top: 5, left: 16, bottom: 5, right: 16)

        containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label

        view.addArrangedSubview(titleLabel)

        let toggle = UISwitch()
        toggle.onTintColor = .brand(.secondaryButtonBackgroundColor)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        view.addArrangedSubview(toggle)

        return (containerView, Signal { callback in
            bag += toggle.signal(for: .valueChanged)
                .map { toggle.isOn }
                .onValue { isOn in
                    callback([data.key: String(isOn)])
                }
            return bag
        })
    }
}
