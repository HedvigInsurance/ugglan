import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct MultiActionSwitchRow { let data: EmbarkSwitchActionData }

extension MultiActionSwitchRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
        let bag = DisposeBag()

        let containerView = UIView()
        bag += containerView.traitCollectionSignal.onValue { trait in
            switch trait.userInterfaceStyle {
            case .dark: containerView.backgroundColor = .grayscale(.grayFive)
            default: containerView.backgroundColor = .brandNew(.primaryBackground())
            }
        }

        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 10
        view.edgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)

        containerView.addSubview(view)
        view.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label

        view.addArrangedSubview(titleLabel)

        let toggle = UISwitch()
        toggle.onTintColor = .brand(.secondaryButtonBackgroundColor)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        view.addArrangedSubview(toggle)

        return (
            containerView,
            Signal { callback in
                bag += toggle.signal(for: .valueChanged).atOnce().map { toggle.isOn }
                    .onValue { isOn in
                        let value = MultiActionValue(
                            inputValue: String(isOn),
                            displayValue: isOn ? data.label : nil,
                            isValid: true
                        )
                        callback([data.key: value])
                    }
                return bag
            }
        )
    }
}
