//
//  PaymentRow.swift
//  Hedvig
//
//  Created by Isaac Sennerholt on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct BankRow {}

extension BankRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: "SEB", style: .rowTitle)

        row.append("*** 8672", style: .rowTitleDisabled)

        return (row, bag)
    }
}
