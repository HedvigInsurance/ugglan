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
import UIKit

struct MyInfoRow {
    let nameSignal = ReadWriteSignal<(firstName: String, lastName: String)?>(nil)
    let presentingViewController: UIViewController
}

extension MyInfoRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.profileMyInfoRowTitle,
            subtitle: "",
            iconAsset: Asset.myInfoRowIcon,
            options: [.withArrow]
        )

        bag += nameSignal.atOnce().compactMap { $0 }.map { firstName, lastName -> String in
            "\(firstName) \(lastName)"
        }.bindTo(row.subtitle)

        bag += events.onSelect.onValue {
            let myInfo = MyInfo()
            self.presentingViewController.present(
                myInfo,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension MyInfoRow: Previewable {
    func preview() -> (MyInfo, PresentationOptions) {
        return (MyInfo(), [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
