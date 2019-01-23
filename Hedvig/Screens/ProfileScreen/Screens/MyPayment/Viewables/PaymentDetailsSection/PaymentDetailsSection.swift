//
//  PaymentDetailsSection.swift
//  Hedvig
//
//  Created by Isaac Sennerholt on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct PaymentDetailsSection {
    let insurance: ProfileQuery.Data.Insurance
}

extension PaymentDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: "",
            footer: nil,
            style: .sectionPlain
        )

        let paymentRow = PaymentRow()
        bag += section.append(paymentRow)

        return (section, bag)
    }
}
