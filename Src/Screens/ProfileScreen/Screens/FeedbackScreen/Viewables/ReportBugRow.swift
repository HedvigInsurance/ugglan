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
    func materialize(events: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()
        
        let row = KeyValueRow()
        
        let emailAddress = "ios@hedvig.com"
        
        row.keySignal.value = "Rapportera bugg"
        row.valueSignal.value = emailAddress
        
        row.valueStyleSignal.value = .rowTitlePurple
    
        bag += events.onSelect.onValue { _ in
            if let url = URL(string: "mailto:\(emailAddress)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        return (row, bag)
    }
}
