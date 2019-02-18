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
    let presentingViewController: UIViewController
}

extension HomeRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String(.PROFILE_MY_HOME_ROW_TITLE),
            subtitle: "",
            iconAsset: Asset.home,
            options: [.withArrow]
        )

        bag += address.atOnce().bindTo(row.subtitle)

        bag += events.onSelect.onValue { _ in
            let myHome = MyHome()
            self.presentingViewController.present(
                myHome,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension HomeRow: Previewable {
    func preview() -> (MyHome, PresentationOptions) {
        return (MyHome(), [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
