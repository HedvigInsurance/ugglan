import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

struct MultiActionSwitchRow {
    let data: EmbarkSwitchActionData
}

extension MultiActionSwitchRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 10
        view.edgeInsets = .init(top: 5, left: 16, bottom: 5, right: 16)

        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label

        view.addArrangedSubview(titleLabel)

        let toggle = UISwitch()
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        view.addArrangedSubview(toggle)

        return (view, Signal { callback in
            bag += toggle.signal(for: .valueChanged)
                .map { toggle.isOn }
                .onValue { isOn in
                    callback([data.key: isOn])
                }
            return bag
        })
    }
}
