//
//  MyCoinsuredRow.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-05.
//

import Flow
import Form
import Foundation
import Presentation

struct MyCoinsuredRow {
    let amountOfCoinsuredSignal = ReadWriteSignal<Int?>(nil)
    let presentingViewController: UIViewController
}

extension MyCoinsuredRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String(key: .PROFILE_MY_COINSURED_ROW_TITLE),
            subtitle: "",
            iconAsset: Asset.coinsured,
            options: [.withArrow]
        )

        bag += amountOfCoinsuredSignal.atOnce().compactMap { $0 }.map {
            String(key: .PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured: String($0 - 1)))
        }.bindTo(row.subtitle)

        bag += amountOfCoinsuredSignal.atOnce().map {
            if $0 == nil || $0 == 1 {
                return [.hidden]
            } else {
                return [.withArrow]
            }
        }.bindTo(row.options)

        bag += events.onSelect.onValue { _ in
            self.presentingViewController.present(
                MyCoinsured(),
                options: [.largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension MyCoinsuredRow: Previewable {
    func preview() -> (MyCoinsured, PresentationOptions) {
        let charity = MyCoinsured()
        return (charity, [.largeTitleDisplayMode(.never)])
    }
}
