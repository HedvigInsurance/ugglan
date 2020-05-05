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
import UIKit

struct LicensesRow {
    let presentingViewController: UIViewController
}

extension LicensesRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: L10n.aboutLicensesRow, style: .rowTitle))

        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)

        row.append(arrow)

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        bag += events.onSelect.onValue {
           
        }

        return (row, bag)
    }
}
