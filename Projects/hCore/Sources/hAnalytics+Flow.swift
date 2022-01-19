//
//  hAnalytics+Flow.swift
//  hCore
//
//  Created by Sam Pettersson on 2022-01-17.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import UIKit
import hAnalytics

extension UIViewController {
    /// sends a tracking event when didMoveToWindow is called
    public func trackDidMoveToWindow(_ track: hAnalytics.AnalyticsClosure) -> Disposable {
        self.view.didMoveToWindowSignal.onValue { _ in
            track.send()
        }
    }
}
