//
//  WhenTooltip.swift
//  hCoreUI
//
//  Created by sam on 14.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import Presentation
import UIKit

extension TimeInterval {
    static func days(numberOfDays: Int) -> TimeInterval {
        Double(numberOfDays) * 24 * 60 * 60
    }
}

public struct WhenTooltip {
    enum When {
        case onceEvery(timeInterval: TimeInterval)
    }

    let when: When
    let tooltip: Tooltip

    var userDefaultsKey: String {
        "tooltip_\(tooltip.id)_past_date"
    }

    /// reset eventual external dependencies like time
    func reset() {
        UserDefaults.standard.setValue(nil, forKey: userDefaultsKey)
    }

    init(
        when: When,
        tooltip: Tooltip
    ) {
        self.when = when
        self.tooltip = tooltip
    }
}

extension UIView {
    func present(_ whenTooltip: WhenTooltip) -> Disposable {
        let pastDate = UserDefaults.standard.value(forKey: whenTooltip.userDefaultsKey) as? Date

        func setDefaultsTime() {
            UserDefaults.standard.setValue(Date(), forKey: whenTooltip.userDefaultsKey)
        }

        if let pastDate = pastDate {
            switch whenTooltip.when {
            case let .onceEvery(timeInterval):
                let timeIntervalSincePast = abs(pastDate.timeIntervalSince(Date()))

                if timeIntervalSincePast > timeInterval {
                    setDefaultsTime()
                    return present(whenTooltip.tooltip)
                }
            }

            return NilDisposer()
        }

        setDefaultsTime()
        return present(whenTooltip.tooltip)
    }
}
