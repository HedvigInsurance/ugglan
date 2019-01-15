//
//  EmailRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct EmailRow {}

extension EmailRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: String.translation(.EMAIL_ROW_TITLE), style: .rowTitle)

        row.append(String.translation(.EMAIL_ROW_EMPTY), style: .rowTitleDisabled)

        return (row, bag)
    }
}
