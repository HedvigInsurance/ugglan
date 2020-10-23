import Flow
import Foundation
import hCore
import Presentation
import UIKit

public struct PaymentSetup {
    let setupType: SetupType
    let urlScheme: String

    public enum SetupType {
        case initial, replacement, postOnboarding
    }

    public init(
        setupType: SetupType,
        urlScheme: String
    ) {
        self.setupType = setupType
        self.urlScheme = urlScheme
    }
}

extension PaymentSetup: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        switch Localization.Locale.currentLocale.market {
        case .se:
            return DirectDebitSetup(setupType: setupType).materialize()
        case .no, .dk:
            return AdyenSetup(urlScheme: urlScheme).materialize()
        }
    }
}
