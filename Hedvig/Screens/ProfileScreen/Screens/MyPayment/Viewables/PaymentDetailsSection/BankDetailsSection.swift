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

struct BankDetailsSection {
    let insurance: ProfileQuery.Data.Insurance
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(.MY_PAYMENT_BANK_ROW_LABEL),
            footer: nil,
            style: .sectionPlain
        )

        let bankRow = BankRow()
        bag += section.append(bankRow)

        return (section, bag)
    }
}
