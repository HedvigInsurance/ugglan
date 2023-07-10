import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct MyInfoRow {
    let nameSignal = ReadWriteSignal<(firstName: String, lastName: String)?>(nil)
    let presentingViewController: UIViewController
}

extension MyInfoRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.profileMyInfoRowTitle,
            subtitle: "",
            iconAsset: hCoreUIAssets.myInfoRowIcon.image,
            options: [.withArrow]
        )

        bag += nameSignal.atOnce().compactMap { $0 }
            .map { firstName, lastName -> String in "\(firstName) \(lastName)" }.bindTo(row.subtitle)

        bag += events.onSelect.onValue {
            let myInfo = MyInfo()
            self.presentingViewController.present(
                myInfo,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}
