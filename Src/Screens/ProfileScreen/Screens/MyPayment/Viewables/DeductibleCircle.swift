//
//  MonthlyCostCircle.swift
//  Hedvig
//
//  Created by Isaac Sennerholt on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

struct DeductibleCircle {}

extension DeductibleCircle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let deductibleCircleText = DynamicString(String(.MY_PAYMENT_DEDUCTIBLE_CIRCLE))

        let deductibleCircle = CircleLabelSmall(
            labelText: deductibleCircleText,
            color: .green
        )

        bag += containerView.add(deductibleCircle)

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(80)
            make.centerX.equalToSuperview().inset(80)
            make.bottom.equalTo(0)
        }

        return (containerView, bag)
    }
}
