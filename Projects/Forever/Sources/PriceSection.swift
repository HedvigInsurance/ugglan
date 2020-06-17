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
}

extension PriceSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let section = SectionView()
        let bag = DisposeBag()

        let row = RowView()

        let discountStackView = UIStackView()
        discountStackView.spacing = 5
        discountStackView.axis = .vertical

        row.append(discountStackView)

        discountStackView.addArrangedSubview(UILabel(value: "Discount per month", style: .brand(.footnote(color: .tertiary))))

        bag += discountStackView.addArranged(AnimatedMoneyLabel(value: grossAmountSignal))

        let netAmountStackView = UIStackView()
        netAmountStackView.spacing = 10
        netAmountStackView.axis = .vertical

        row.append(netAmountStackView)

        netAmountStackView.addArrangedSubview(UILabel(value: "Your new price", style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .right)))
        netAmountStackView.addArrangedSubview(UILabel(value: "339 SEK", style: TextStyle.brand(.title2(color: .primary)).aligned(to: .right)))

        section.append(row)

        return (section, bag)
    }
}
