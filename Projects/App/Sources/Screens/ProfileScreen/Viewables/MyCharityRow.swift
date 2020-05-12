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
import UIKit
import hCore

struct MyCharityRow {
    let charityNameSignal = ReadWriteSignal<String?>(nil)
    let presentingViewController: UIViewController
}

extension MyCharityRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.profileMyCharityRowTitle,
            subtitle: "",
            iconAsset: Asset.charityPlain,
            options: [.withArrow]
        )

        bag += charityNameSignal.atOnce().map { charityName -> String in
            charityName ?? L10n.profileMyCharityRowNotSelectedSubtitle
        }.bindTo(row.subtitle)

        bag += events.onSelect.onValue { _ in
            self.presentingViewController.present(
                Charity(),
                options: [.largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension MyCharityRow: Previewable {
    func preview() -> (Charity, PresentationOptions) {
        let charity = Charity()
        return (charity, [.largeTitleDisplayMode(.never)])
    }
}
