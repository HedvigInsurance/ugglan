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

struct MonthlyPaymentCircle {
    let monthlyCost: Int
}

extension MonthlyPaymentCircle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let monthlyPaymentCircle = CircleLabelWithSubLabel(
            labelText: DynamicString(String(monthlyCost)),
            subLabelText: DynamicString(String(.PAYMENT_CURRENCY_OCCURRENCE)),
            appearance: .turquoise
        )
        bag += containerView.add(monthlyPaymentCircle)

        let deductibleCircle = DeductibleCircle()
        bag += containerView.add(deductibleCircle)

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(200)
        }

        return (containerView, bag)
    }
}
