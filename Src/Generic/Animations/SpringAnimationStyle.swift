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
    var options: UIView.AnimationOptions

    init(duration: TimeInterval, damping: CGFloat, velocity: CGFloat, delay: TimeInterval, options: UIView.AnimationOptions = [.allowUserInteraction]) {
        self.duration = duration
        self.damping = damping
        self.velocity = velocity
        self.delay = delay
        self.options = options
    }
}

extension SpringAnimationStyle {
    static func lightBounce(delay: TimeInterval = 0, duration: TimeInterval = 0.5) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            duration: duration,
            damping: 30,
            velocity: 1,
            delay: delay,
            options: [.allowUserInteraction]
        )
    }

    static func mediumBounce(delay: TimeInterval = 0, duration: TimeInterval = 0.6) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            duration: duration,
            damping: 10,
            velocity: 1.7,
            delay: delay,
            options: [.allowUserInteraction]
        )
    }

    static func heavyBounce(delay: TimeInterval = 0, duration: TimeInterval = 0.6) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            duration: duration,
            damping: 0.6,
            velocity: 2,
            delay: delay,
            options: [.allowUserInteraction]
        )
    }

    static func ludicrousBounce(delay: TimeInterval = 0, duration: TimeInterval = 0.6) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            duration: duration,
            damping: 0.2,
            velocity: 3,
            delay: delay,
            options: [.allowUserInteraction]
        )
    }
}
