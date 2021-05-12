import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

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
			iconAsset: Asset.charityPlain.image,
			options: [.withArrow]
		)

		bag += charityNameSignal.atOnce()
			.map { charityName -> String in charityName ?? L10n.profileMyCharityRowNotSelectedSubtitle }
			.bindTo(row.subtitle)

		bag += events.onSelect.onValue { _ in
			self.presentingViewController.present(Charity(), options: [.largeTitleDisplayMode(.never)])
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
