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
    var service: ForeverService
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
        
        bag += service.dataSignal.compactMap { $0?.grossAmount }.animated(style: SpringAnimationStyle.lightBounce()) { amount in
            piePrice.value = amount.formattedAmount
            piePrice.alpha = 1
        }

        let pieChart = PieChart(stateSignal: .init(.init(percentagePerSlice: 0, slices: 0)))
        bag += stackView.addArranged(pieChart)

        let emptyStateHeader = EmptyStateHeader(potentialDiscountAmountSignal: service.dataSignal.map { $0?.potentialDiscountAmount })
        emptyStateHeader.isHiddenSignal.value = true
        
        bag += stackView.addArranged(emptyStateHeader)

        let priceSection = PriceSection(grossAmountSignal: service.dataSignal.map { $0?.grossAmount }, netAmountSignal: service.dataSignal.map { $0?.netAmount })
        priceSection.isHiddenSignal.value = true
        bag += stackView.addArranged(priceSection)
        
        bag += stackView.addArranged(Spacing(height: 20))

        let discountCodeSection = DiscountCodeSection(
            service: service,
            discountCodeSignal: service.dataSignal.map { $0?.discountCode },
            potentialDiscountAmountSignal: service.dataSignal.map { $0?.potentialDiscountAmount }
        )
        bag += stackView.addArranged(discountCodeSection)

        bag += combineLatest(
            service.dataSignal.map { $0?.grossAmount }.atOnce().compactMap { $0 },
            service.dataSignal.map { $0?.netAmount }.atOnce().compactMap { $0 },
            service.dataSignal.map { $0?.potentialDiscountAmount }.atOnce().compactMap { $0 }
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
