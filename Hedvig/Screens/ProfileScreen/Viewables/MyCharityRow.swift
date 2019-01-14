//
//  MyCharityRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct MyCharityRow {
    let charityName: String
}

extension MyCharityRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String.translation(.PROFILE_MY_CHARITY_ROW_TITLE),
            subtitle: charityName,
            iconAsset: Asset.charity
        )

        return (row, bag)
    }
}
