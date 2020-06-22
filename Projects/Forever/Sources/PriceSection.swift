//
//  PriceSection.swift
//  Forever
//
//  Created by sam on 17.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Ease
import Flow
import Form
import Foundation
import hCore
import UIKit

struct PriceSection {
    let grossAmountSignal: ReadSignal<MonetaryAmount?>
    let netAmountSignal: ReadSignal<MonetaryAmount?>
    let isHiddenSignal = ReadWriteSignal<Bool>(false)
}

extension PriceSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let section = SectionView()
        let bag = DisposeBag()
        let row = RowView()
        section.isHidden = isHiddenSignal.value
        
        bag += isHiddenSignal.bindTo(animate: SpringAnimationStyle.lightBounce(), section, \.animationSafeIsHidden)

        let discountStackView = UIStackView()
        discountStackView.spacing = 5
        discountStackView.axis = .vertical

        row.append(discountStackView)

        discountStackView.addArrangedSubview(UILabel(value: L10n.ReferralsActive.Discount.Per.Month.title, style: .brand(.footnote(color: .tertiary))))
        bag += discountStackView.addArranged(AnimatedSavingsLabel(
            from: combineLatest(grossAmountSignal, netAmountSignal).filter { grossAmount, netAmount in grossAmount != nil && netAmount != nil }.toVoid().map { _ in MonetaryAmount(amount: "0.00", currency: "SEK") }.readable(initial: nil),
            to: combineLatest(grossAmountSignal, netAmountSignal).map { grossAmount, netAmount in MonetaryAmount(amount: (grossAmount?.value ?? 0) - (netAmount?.value ?? 0), currency: grossAmount?.currency ?? "") })
        )

        let netAmountStackView = UIStackView()
        netAmountStackView.spacing = 10
        netAmountStackView.axis = .vertical

        row.append(netAmountStackView)

        netAmountStackView.addArrangedSubview(UILabel(value: L10n.ReferralsActive.Your.New.Price.title, style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .right)))
        bag += netAmountStackView.addArranged(AnimatedSavingsLabel(from: grossAmountSignal, to: netAmountSignal))

        section.append(row)

        return (section, bag)
    }
}
