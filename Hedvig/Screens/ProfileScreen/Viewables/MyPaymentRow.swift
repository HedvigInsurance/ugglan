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

struct MyPaymentRow {
    let monthlyCost: Int
    let presentingViewController: UIViewController
}

extension MyPaymentRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String(.PROFILE_PAYMENT_ROW_HEADER),
            subtitle: "\(monthlyCost) kr/XYZ • \(String(.PROFILE_MY_PAYMENT_METHOD))",
            iconAsset: Asset.payment
        )

        bag += events.onSelect.onValue {
            let myPayment = MyPayment(presentingViewController: self.presentingViewController)
            self.presentingViewController.present(myPayment, style: .default, options: [.largeTitleDisplayMode(.never)])
        }

        return (row, bag)
    }
}

extension MyPaymentRow: Previewable {
    func preview() -> (MyPayment, PresentationOptions) {
        return (MyPayment(presentingViewController: presentingViewController), [.largeTitleDisplayMode(.never)])
    }
}
