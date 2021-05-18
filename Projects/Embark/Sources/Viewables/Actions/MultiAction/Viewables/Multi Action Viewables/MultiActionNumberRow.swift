import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

struct MultiActionNumberRow {
    let data: EmbarkNumberActionFragment
}

extension MultiActionNumberRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.edgeInsets = .init(top: 5, left: 16, bottom: 5, right: 16)

        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        view.addArrangedSubview(titleLabel)

        let masking = Masking(type: .digits)
        let numberField = EmbarkInput(
            placeholder: data.placeholder,
            keyboardType: masking.keyboardType,
            textContentType: masking.textContentType,
            autocapitalisationType: masking.autocapitalizationType,
            insets: .zero,
            masking: masking,
            fieldStyle: .embarkInputSmall,
            textFieldAlignment: .right
        )

        return (view, Signal { callback in
            bag += view.addArranged(numberField).onValue { text in
                callback([data.key: text])
            }

            return bag
        })
    }
}
