import Flow
import Form
import Foundation
import hCore
import Payment
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
			iconAsset: Asset.paymentRowIcon.image,
			options: [.withArrow]
		)

		bag += monthlyCostSignal.atOnce().compactMap { $0 }
			.map { monthlyCost in
				"\(monthlyCost) \(L10n.paymentCurrencyOccurrence) · \(L10n.profileMyPaymentMethod)"
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

extension MyPaymentRow: Previewable {
	func preview() -> (MyPayment, PresentationOptions) {
		return (MyPayment(urlScheme: Bundle.main.urlScheme ?? ""), [.largeTitleDisplayMode(.never)])
	}
}
