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

struct MyPaymentRow {
    let monthlyCostSignal = ReadWriteSignal<Int?>(nil)
    let presentingViewController: UIViewController
}

extension MyPaymentRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.profilePaymentRowHeader,
            subtitle: "",
            iconAsset: Asset.paymentRowIcon,
            options: [.withArrow]
        )

        bag += monthlyCostSignal.atOnce().compactMap { $0 }.map { monthlyCost in
            "\(monthlyCost) \(L10n.paymentCurrencyOccurrence) · \(L10n.profileMyPaymentMethod)"
        }.bindTo(row.subtitle)

        bag += events.onSelect.onValue {
            let myPayment = MyPayment()
            self.presentingViewController.present(myPayment, style: .default, options: [.largeTitleDisplayMode(.never)])
        }

        return (row, bag)
    }
}

extension MyPaymentRow: Previewable {
    func preview() -> (MyPayment, PresentationOptions) {
        return (MyPayment(), [.largeTitleDisplayMode(.never)])
    }
}
