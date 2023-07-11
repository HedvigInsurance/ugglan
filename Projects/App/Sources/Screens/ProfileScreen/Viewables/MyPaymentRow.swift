import Flow
import Form
import Foundation
import Payment
import Presentation
import UIKit
import hCore
import hCoreUI

struct MyPaymentRow {
    let monthlyCostSignal = ReadWriteSignal<String?>(nil)
    let presentingViewController: UIViewController
}

extension MyPaymentRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.profilePaymentRowHeader,
            subtitle: "",
            iconAsset: hCoreUIAssets.payments.image,
            options: [.withArrow]
        )

        bag += monthlyCostSignal.atOnce().compactMap { $0 }
            .map { monthlyCost in
                "\(monthlyCost) \(L10n.paymentCurrencyOccurrence)"
            }
            .bindTo(row.subtitle)

        bag += events.onSelect.onValue {
            let myPayment = MyPayment(urlScheme: Bundle.main.urlScheme ?? "")
            self.presentingViewController.present(
                myPayment,
                style: .default,
                options: [.largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}
