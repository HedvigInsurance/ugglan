//
//  LanguageRow.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-17.
//

import Flow
import Form
import Foundation
import Presentation

struct LanguageRow {
    let presentingViewController: UIViewController
}

extension LanguageRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: "Language/Språk", style: .rowTitle))

        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)

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

