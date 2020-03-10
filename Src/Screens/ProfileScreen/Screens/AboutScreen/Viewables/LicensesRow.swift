//
//  LicensesRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import ComponentKit

struct LicensesRow {
    let presentingViewController: UIViewController
}

extension LicensesRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: String(key: .ABOUT_LICENSES_ROW), style: .rowTitle))

        let arrow = Icon(frame: .zero, icon: Asset.chevronRight.image, iconWidth: 20)

        row.append(arrow)

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        bag += events.onSelect.onValue {
            self.presentingViewController.present(
                Licenses(),
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension LicensesRow: Previewable {
    func preview() -> (Licenses, PresentationOptions) {
        return (Licenses(), [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
