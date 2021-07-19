import Flow
import Form
import Foundation
import UIKit
import hCore

struct SettingsSection { let presentingViewController: UIViewController }

extension SettingsSection: Viewable {
	func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
		let bag = DisposeBag()
		let section = SectionView(header: L10n.Profile.AppSettingsSection.title, footer: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .largeIcons)

		let appInformationRow = SettingsRow(
			presentingViewController: presentingViewController,
			type: .appInformation
		)
		bag += section.append(appInformationRow)

		let appSettingsRow = SettingsRow(presentingViewController: presentingViewController, type: .appSettings)
		bag += section.append(appSettingsRow)

		let logoutRow = LogoutRow(presentingViewController: presentingViewController)
		bag += section.append(logoutRow)

		return (section, bag)
	}
}
