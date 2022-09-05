import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore

struct MyCharityRow {
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
