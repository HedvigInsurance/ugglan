//
//  AnimatedMoneyLabel.swift
//  Forever
//
//  Created by sam on 17.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

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

        return (label, bag)
    }
}
