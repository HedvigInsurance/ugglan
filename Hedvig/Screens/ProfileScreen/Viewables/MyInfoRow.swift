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
    func materialize(events: ViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let myInfoRow = IconRow(
            title: "Min info",
            subtitle: "blabla",
            iconAsset: Asset.personalInformation
        )

        bag += events.onSelect.onValue {
            print("i was selected")
        }

        return (myInfoRow, bag)
    }
}
