//
//  AnimatedMoneyLabel.swift
//  Forever
//
//  Created by sam on 17.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Ease
import Flow
import Foundation
import hCore
import UIKit

struct AnimatedMoneyLabel {
    let value: ReadSignal<MonetaryAmount?>
}

extension AnimatedMoneyLabel: Viewable {
    func materialize(events _: ViewableEvents) -> (UILabel, Disposable) {
        let label = UILabel()
        let bag = DisposeBag()

        let ease: Ease<CGFloat> = Ease(0, minimumStep: 1)

        bag += ease.addSpring(tension: 300, damping: 100, mass: 2) { number in
            label.value = MonetaryAmount(amount: String(Int(number)), currency: self.value.value?.currency ?? "").formattedAmount
        }

        ease.targetValue = 100

        bag += value.atOnce().compactMap { $0 }.onValue { amount in
            ease.targetValue = CGFloat(amount.value)
        }

        return (label, bag)
    }
}
