//
//  UIControl+Tracking.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-06.
//

import Firebase
import Flow
import Foundation
import UIKit

extension UIControl {
    /// Triggers on touchUpInside and uses accessibilityLabel to trigger an analytics event
    var trackedTouchUpInsideSignal: Signal<Void> {
        return signal(for: .touchUpInside).atValue {
            if let accessibilityLabel = self.accessibilityLabel {
                if let localizationKey = accessibilityLabel.localizationKey?.description {
                    Analytics.logEvent(localizationKey, parameters: [
                        "context": "UIControl",
                    ])
                }
            } else if let accessibilityIdentifier = self.accessibilityIdentifier {
                Analytics.logEvent(accessibilityIdentifier, parameters: [
                    "context": "UIControl",
                ])
            }
        }
    }
}
