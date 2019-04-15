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
import StoreKit

struct ReviewAppRow {}

extension ReviewAppRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()

        let row = KeyValueRow()

        row.keySignal.value = String(key: .FEEDBACK_SCREEN_REVIEW_APP_TITLE)
        row.valueSignal.value = String(key: .FEEDBACK_SCREEN_REVIEW_APP_VALUE)

        row.valueStyleSignal.value = .rowValueLink

        let reviewURL = String(key: .APP_STORE_REVIEW_URL)

        bag += events.onSelect.onValue { _ in
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                guard let url = URL(string: reviewURL), UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.openURL(url)
            }
        }

        return (row, bag)
    }
}
