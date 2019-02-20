//
//  RateAppRow.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct ReviewAppRow {}

extension ReviewAppRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()
        
        let row = KeyValueRow()
        
        row.keySignal.value = String(.FEEDBACK_SCREEN_REVIEW_APP_TITLE)
        row.valueSignal.value = String(.FEEDBACK_SCREEN_REVIEW_APP_VALUE)
        
        row.valueStyleSignal.value = .rowTitlePurple
        
        let appID = "1303668531"
        let reviewURL = "itms-apps://itunes.apple.com/app/\(appID)?action=write-review"
        
        bag += events.onSelect.onValue { _ in
            if let url = URL(string: reviewURL), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        return (row, bag)
    }
}
