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
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10

        let titleLabel = UILabel()
        titleLabel.style = .brand(.title1(color: .primary))
        titleLabel.text = data.label

        view.addArrangedSubview(titleLabel)

        var dictionary = [String: Any]()

        let masking = Masking(type: .digits)
        let numberField = EmbarkInput(
            placeholder: data.placeholder,
            keyboardType: masking.keyboardType,
            textContentType: masking.textContentType,
            autocapitalisationType: masking.autocapitalizationType,
            masking: masking,
            fieldStyle: .embarkInputSmall
        )

        bag += view.addArranged(numberField).onValue { text in
            dictionary[data.key] = text
        }

        return (view, bag)
    }
}
