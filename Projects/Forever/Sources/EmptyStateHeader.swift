import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct EmptyStateHeader {
    let isHiddenSignal = ReadWriteSignal<Bool>(true)
    let potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>
}

extension EmptyStateHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isHidden = isHiddenSignal.value

        bag += isHiddenSignal.bindTo(
            animate: SpringAnimationStyle.lightBounce(),
            stackView,
            \.animationSafeIsHidden
        )

        let title = MultilineLabel(
            value: L10n.ReferralsEmpty.headline,
            style: TextStyle.brand(.title1(color: .primary)).centerAligned
        )
        bag += stackView.addArranged(title)

        var body = MultilineLabel(value: "", style: TextStyle.brand(.body(color: .secondary)).centerAligned)
        bag += stackView.addArranged(body)

        bag += potentialDiscountAmountSignal.compactMap { $0 }
            .onValue { amount in
                body.value = L10n.ReferralsEmpty.body(
                    amount.formattedAmount,
                    MonetaryAmount(amount: 0, currency: amount.currency).formattedAmount
                )
            }

        return (stackView, bag)
    }
}
