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
import Presentation

struct MyInfoRow {
    let presentingViewController: UIViewController
}

extension MyInfoRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let myInfoRow = IconRow(
            title: "Min info",
            subtitle: "blabla",
            iconAsset: Asset.personalInformation
        )

        bag += events.onSelect.onValue {
            let myInfo = MyInfo()
            self.presentingViewController.present(myInfo, style: .default, options: [.autoPop])
        }

        return (myInfoRow, bag)
    }
}
