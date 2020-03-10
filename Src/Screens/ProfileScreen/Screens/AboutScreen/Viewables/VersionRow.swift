//
//  VersionRow.swift
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

struct VersionRow {}

extension VersionRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: "Version", style: .rowTitle))

        let appVersion = Bundle.main.appVersion

        row.append(UILabel(value: appVersion, style: .rowTitleDisabled))

        return (row, bag)
    }
}
