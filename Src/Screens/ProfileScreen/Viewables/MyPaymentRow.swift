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
import Common

struct MyPaymentRow {
    let monthlyCostSignal = ReadWriteSignal<Int?>(nil)
    let presentingViewController: UIViewController
}

extension MyPaymentRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String(key: .PROFILE_PAYMENT_ROW_HEADER),
            subtitle: "",
            iconAsset: Asset.paymentRowIcon,
            options: [.withArrow]
        )

        bag += monthlyCostSignal.atOnce().compactMap { $0 }.map { monthlyCost in
            "\(monthlyCost) \(String(key: .PAYMENT_CURRENCY_OCCURRENCE)) · \(String(key: .PROFILE_MY_PAYMENT_METHOD))"
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
