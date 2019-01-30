//
//  HomeRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct HomeRow {
    let address: ReadWriteSignal<String> = ReadWriteSignal("")
}

extension HomeRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String(.PROFILE_MY_HOME_ROW_TITLE),
            subtitle: "",
            iconAsset: Asset.home
        )

        bag += address.atOnce().bindTo(row.subtitle)

        return (row, bag)
    }
}
