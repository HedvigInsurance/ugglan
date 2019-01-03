//
//  MyInfoRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct MyInfoRow {}

extension MyInfoRow: Viewable {
    func materialize(events: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let myInfoRow = IconRow(
            title: "Min info",
            subtitle: "blabla adam",
            iconAsset: Asset.personalInformation
        )

        let (rowView, innerBag) = myInfoRow.materialize(events: events)
        bag += innerBag

        return (rowView, bag)
    }
}
