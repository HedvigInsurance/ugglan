//
//  Header.swift
//  Forever
//
//  Created by sam on 4.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit
import Form

struct Header {
    let grossAmountSignal: ReadSignal<MonetaryAmount?>
    let netAmountSignal: ReadSignal<MonetaryAmount?>
    let discountCodeSignal: ReadSignal<String?>
    let potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>
}

extension Header: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 24, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        let bag = DisposeBag()
        
        let piePrice = UILabel(value: "\u{00a0}", style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .center))
        piePrice.alpha = 0
        stackView.addArrangedSubview(piePrice)
        
        bag += grossAmountSignal.compactMap { $0 }.animated(style: SpringAnimationStyle.lightBounce()) { amount in
            piePrice.value = amount.formattedAmount
            piePrice.alpha = 1
        }

        let pieChart = PieChart(stateSignal: .init(.init(percentagePerSlice: 0, slices: 0)))
        bag += stackView.addArranged(pieChart)

        let emptyStateHeader = EmptyStateHeader(potentialDiscountAmountSignal: potentialDiscountAmountSignal)
        emptyStateHeader.isHiddenSignal.value = true
        
        bag += stackView.addArranged(emptyStateHeader)

        let priceSection = PriceSection(grossAmountSignal: grossAmountSignal, netAmountSignal: netAmountSignal)
        priceSection.isHiddenSignal.value = true
        bag += stackView.addArranged(priceSection)
        
        bag += stackView.addArranged(Spacing(height: 20))

        let discountCodeSection = DiscountCodeSection(discountCodeSignal: discountCodeSignal)
        bag += stackView.addArranged(discountCodeSection)

        bag += combineLatest(
            grossAmountSignal.atOnce().compactMap { $0 },
            netAmountSignal.atOnce().compactMap { $0 },
            potentialDiscountAmountSignal.atOnce().compactMap { $0 }
        ).onValue { grossAmount, netAmount, potentialDiscountAmount in
            bag += Signal(after: 0.8).onValue { _ in
                pieChart.stateSignal.value = .init(
                    grossAmount: grossAmount,
                    netAmount: netAmount,
                    potentialDiscountAmount: potentialDiscountAmount
                )
            }

            emptyStateHeader.isHiddenSignal.value = grossAmount.amount != netAmount.amount
            priceSection.isHiddenSignal.value = grossAmount.amount == netAmount.amount
        }

        return (stackView, bag)
    }
}
