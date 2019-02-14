//
//  ReportBugRow.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct ReportBugRow {}

extension ReportBugRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()
        
        let row = KeyValueRow()
        
        row.keySignal.value = "Rapportera bugg"
        row.valueSignal.value = "ios@hedvig.com"
        
        row.valueStyleSignal.value = .rowTitleDisabled
        
        return (row, bag)
    }
}
