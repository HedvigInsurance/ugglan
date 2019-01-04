//
//  TransitionStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

struct TransitionStyle {
    var duration: TimeInterval
    var options: UIView.AnimationOptions

    init(duration: TimeInterval, options: UIView.AnimationOptions) {
        self.duration = duration
        self.options = options
    }
}

extension TransitionStyle {
    static func crossDissolve(duration: TimeInterval) -> TransitionStyle {
        return TransitionStyle(duration: duration, options: .transitionCrossDissolve)
    }
}
