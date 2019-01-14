//
//  PhoneNumberRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct PhoneNumberRow {}

extension PhoneNumberRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: String.translation(.PHONE_NUMBER_ROW_TITLE), style: .rowTitle)

        row.append(String.translation(.PHONE_NUMBER_ROW_EMPTY), style: .rowTitleDisabled)

        return (row, bag)
    }
}
