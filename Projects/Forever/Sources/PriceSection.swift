import Flow
import Form
import Foundation
import UIKit
import hCore
import hGraphQL

struct PriceSection {
    let grossAmountSignal: ReadSignal<MonetaryAmount?>
    let netAmountSignal: ReadSignal<MonetaryAmount?>
    let isHiddenSignal = ReadWriteSignal<Bool>(false)
}

extension PriceSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let section = SectionView()
        section.dynamicStyle = .brandGroupedNoBackground
        let bag = DisposeBag()
        let row = RowView()
        section.isHidden = isHiddenSignal.value

        bag += isHiddenSignal.bindTo(
            animate: SpringAnimationStyle.lightBounce(),
            section,
            \.animationSafeIsHidden
        )

        let discountStackView = UIStackView()
        discountStackView.spacing = 5
        discountStackView.axis = .vertical

        row.append(discountStackView)

        discountStackView.addArrangedSubview(
            UILabel(
                value: L10n.ReferralsActive.Discount.Per.Month.title,
                style: .brand(.footnote(color: .tertiary))
            )
        )
        bag += discountStackView.addArranged(
            AnimatedSavingsLabel(
                from: combineLatest(grossAmountSignal, netAmountSignal)
                    .filter { grossAmount, netAmount in grossAmount != nil && netAmount != nil }
                    .map { grossAmount, _ in
                        MonetaryAmount(amount: "0.00", currency: grossAmount?.currency ?? "")
                    }
                    .readable(initial: nil).map { $0?.negative },
                to: combineLatest(grossAmountSignal, netAmountSignal)
                    .map { grossAmount, netAmount in
                        MonetaryAmount(
                            amount: (grossAmount?.value ?? 0) - (netAmount?.value ?? 0),
                            currency: grossAmount?.currency ?? ""
                        )
                    }
                    .map { $0.negative },
                textAlignment: .left
            )
        )

        let netAmountStackView = UIStackView()
        netAmountStackView.spacing = 10
        netAmountStackView.axis = .vertical

        row.append(netAmountStackView)

        netAmountStackView.addArrangedSubview(
            UILabel(
                value: L10n.ReferralsActive.Your.New.Price.title,
                style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .right)
            )
        )
        bag += netAmountStackView.addArranged(
            AnimatedSavingsLabel(from: grossAmountSignal, to: netAmountSignal, textAlignment: .right)
        )

        section.append(row)

        return (section, bag)
    }
}
