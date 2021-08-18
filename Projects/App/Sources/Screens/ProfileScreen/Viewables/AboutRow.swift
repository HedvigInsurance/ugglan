import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct SettingsRow {
    let presentingViewController: UIViewController
    let type: AppInfo.AppInfoType
}

extension SettingsRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(title: type.title, subtitle: "", iconAsset: type.icon, options: [.withArrow])

        bag += events.onSelect.onValue {
            let info = AppInfo(type: type)
            self.presentingViewController.present(
                info,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}
