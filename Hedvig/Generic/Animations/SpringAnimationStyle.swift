//
//  SpringAnimationStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-10.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

struct SpringAnimationStyle {
    var duration: TimeInterval
    var damping: CGFloat
    var velocity: CGFloat
    var delay: TimeInterval

    init(duration: TimeInterval, damping: CGFloat, velocity: CGFloat, delay: TimeInterval) {
        self.duration = duration
        self.damping = damping
        self.velocity = velocity
        self.delay = delay
    }
}

extension SpringAnimationStyle {
    static func lightBounce(delay: TimeInterval = 0) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            duration: 0.5,
            damping: 30,
            velocity: 1,
            delay: delay
        )
    }

    static func heavyBounce(delay: TimeInterval = 0) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            duration: 0.6,
            damping: 0.6,
            velocity: 2,
            delay: delay
        )
    }
}
