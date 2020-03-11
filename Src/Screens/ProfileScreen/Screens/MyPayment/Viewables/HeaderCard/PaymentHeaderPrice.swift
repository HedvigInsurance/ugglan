//
//  PriceDisplay.swift
//  UITests
//
//  Created by Sam Pettersson on 2020-01-20.
//

import Ease
import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct PaymentHeaderPrice {
    let grossPriceSignal: ReadSignal<Int>
    let discountSignal: ReadSignal<Int>
    let monthlyNetPriceSignal: ReadSignal<Int>
}

extension PaymentHeaderPrice: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.alignment = .leading

        let priceLabel = UILabel(value: "", style: TextStyle.largePriceBubbleTitle)
        stackView.addArrangedSubview(priceLabel)

        let grossPriceLabel = UILabel(value: "", style: TextStyle.priceBubbleGrossTitle)
        grossPriceLabel.animationSafeIsHidden = true

        stackView.addArrangedSubview(grossPriceLabel)

        bag += combineLatest(discountSignal, grossPriceSignal)
            .animated(style: SpringAnimationStyle.mediumBounce(), animations: { monthlyDiscount, monthlyGross in
                grossPriceLabel.styledText = StyledText(text: "\(monthlyGross) kr", style: TextStyle.priceBubbleGrossTitle.colored(.hedvig(.white)))
                grossPriceLabel.animationSafeIsHidden = monthlyDiscount == 0
                grossPriceLabel.alpha = monthlyDiscount == 0 ? 0 : 1
            })

        bag += monthlyNetPriceSignal.onValue { amount in
            priceLabel.styledText = StyledText(text: "\(String(Int(amount))) kr", style: TextStyle.largePriceBubbleTitle.colored(.hedvig(.white)))
            priceLabel.layoutIfNeeded()
        }

        return (stackView, bag)
    }
}
