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
    public static var trackingHandler: (_ button: UIControl) -> Void = { _ in }

    /// Triggers on touchUpInside and uses accessibilityLabel to trigger an analytics event
    public var trackedTouchUpInsideSignal: Signal<Void> {
        return signal(for: .touchUpInside).atValue {
            Self.trackingHandler(self)
        }
    }
}
