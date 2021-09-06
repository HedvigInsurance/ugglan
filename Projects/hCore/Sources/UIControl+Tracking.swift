import Flow
import Foundation
import UIKit

extension UIControl {
    /// Triggers on touchUpInside and uses accessibilityLabel to trigger an analytics event
    public var trackedTouchUpInsideSignal: Signal<Void> {
        signal(for: .touchUpInside)
            .atValue { [unowned self] in
                if let accessibilityLabel = self.accessibilityLabel {
                    if let localizationKey = accessibilityLabel.derivedFromL10n?.key {
                        Analytics.track("TAP_\(localizationKey)", properties: ["context": "UIControl"])
                        Analytics.track("BUTTON_CLICK", properties: ["localizationKey": localizationKey])
                    }
                } else if let accessibilityIdentifier = self.accessibilityIdentifier {
                    Analytics.track("TAP_\(accessibilityIdentifier)", properties: ["context": "UIControl"])
                    Analytics.track("BUTTON_CLICK", properties: ["accessibilityIdentifier": accessibilityIdentifier])
                }
            }
    }
}
