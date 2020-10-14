import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import Presentation
import UIKit

struct LanguageRow {
    let presentingViewController: UIViewController
}

extension LanguageRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: L10n.aboutLanguageRow, style: .brand(.headline(color: .primary))))

        let arrow = Icon(frame: .zero, icon: hCoreUIAssets.chevronRight.image, iconWidth: 20)

        row.append(arrow)

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        bag += events.onSelect.onValue {
            self.presentingViewController.present(
                LanguageSwitcher(),
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension LanguageRow: Previewable {
    func preview() -> (LanguageSwitcher, PresentationOptions) {
        return (LanguageSwitcher(), [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
