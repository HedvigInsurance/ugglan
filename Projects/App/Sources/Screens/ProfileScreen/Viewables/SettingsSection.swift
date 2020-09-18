import Flow
import Form
import Foundation
import hCore
import UIKit

struct SettingsSection {
    let presentingViewController: UIViewController
}

extension SettingsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(
            header: L10n.Profile.AppSettingsSection.title,
            footer: nil
        )

        let aboutRow = AboutRow(presentingViewController: presentingViewController)
        bag += section.append(aboutRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: aboutRow
            )
        }

        let logoutRow = LogoutRow(presentingViewController: presentingViewController)
        bag += section.append(logoutRow)

        return (section, bag)
    }
}
