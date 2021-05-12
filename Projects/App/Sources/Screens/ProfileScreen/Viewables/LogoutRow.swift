import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct LogoutRow { let presentingViewController: UIViewController }

extension LogoutRow: Viewable {
	func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
		let bag = DisposeBag()

		let textStyle = TextStyle.brand(.headline(color: .destructive))

		let logoutRow = IconRow(
			title: L10n.logoutButton,
			subtitle: "",
			iconAsset: Asset.logoutIcon.image,
			iconTint: textStyle.color
		)
		logoutRow.titleTextStyle.value = textStyle

		bag += events.onSelect.onValue { _ in
			let alert = Alert<Bool>(
				title: L10n.logoutAlertTitle,
				message: nil,
				tintColor: nil,
				actions: [
					Alert.Action(
						title: L10n.logoutAlertActionCancel,
						style: UIAlertAction.Style.cancel
					) { false },
					Alert.Action(
						title: L10n.logoutAlertActionConfirm,
						style: UIAlertAction.Style.destructive
					) { true }
				]
			)

			bag += self.presentingViewController.present(alert)
				.onValue { shouldLogout in
					if shouldLogout {
						ApplicationState.preserveState(.marketPicker)
						UIApplication.shared.appDelegate.logout()
					}
				}
		}

		return (logoutRow, bag)
	}
}
