import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct AboutRow {
    let presentingViewController: UIViewController
}

extension AboutRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.Profile.AppSettingsSection.Row.headline,
            subtitle: L10n.Profile.AppSettingsSection.Row.subheadline,
            iconAsset: Asset.settingsIcon,
            options: [.withArrow]
        )

        bag += events.onSelect.onValue {
            let about = About(state: .loggedIn)
            self.presentingViewController.present(
                about,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension AboutRow: Previewable {
    func preview() -> (About, PresentationOptions) {
        let about = About(state: .loggedIn)
        return (about, [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
