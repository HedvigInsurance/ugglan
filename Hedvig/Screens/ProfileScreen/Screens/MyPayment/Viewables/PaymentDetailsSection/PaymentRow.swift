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

struct PaymentRow {}

extension PaymentRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView(title: "Autogiro", style: .rowTitle)
        row.append("Den 27:e varje månad", style: .rowTitleDisabled)

        return (row, bag)
    }
}
