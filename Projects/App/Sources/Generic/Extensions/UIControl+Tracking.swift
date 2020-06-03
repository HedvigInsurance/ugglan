//
//  UIControl+Tracking.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-06.
//

import Flow
import Foundation
import Mixpanel
import UIKit

extension UIControl {
    /// Triggers on touchUpInside and uses accessibilityLabel to trigger an analytics event
    var trackedTouchUpInsideSignal: Signal<Void> {
        return signal(for: .touchUpInside).atValue {
            if let accessibilityLabel = self.accessibilityLabel {
                if let localizationKey = accessibilityLabel.derivedFromL10n?.key {
                    Mixpanel.mainInstance().track(event: "TAP_\(localizationKey)", properties: [
                        "context": "UIControl",
                    ])
                }
            } else if let accessibilityIdentifier = self.accessibilityIdentifier {
                Mixpanel.mainInstance().track(event: "TAP_\(accessibilityIdentifier)", properties: [
                    "context": "UIControl",
                ])
            }
        }
    }
}
