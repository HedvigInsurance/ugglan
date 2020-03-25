//
//  PaymentSetup.swift
//  test
//
//  Created by sam on 24.3.20.
//

import Flow
import Foundation
import Presentation
import UIKit

struct PaymentSetup {
    let setupType: SetupType

    enum SetupType {
        case initial, replacement, postOnboarding
    }
}

extension PaymentSetup: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        switch Localization.Locale.currentLocale.market {
        case .se:
            return DirectDebitSetup().materialize()
        case .no:
            return AdyenSetup().materialize()
        }
    }
}
