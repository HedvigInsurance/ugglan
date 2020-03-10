//
//  SpringAnimationStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-10.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

public struct SpringAnimationStyle {
    public var duration: TimeInterval
    public var damping: CGFloat
    public var velocity: CGFloat
    public var delay: TimeInterval
    public var options: UIView.AnimationOptions

    public init(duration: TimeInterval, damping: CGFloat, velocity: CGFloat, delay: TimeInterval, options: UIView.AnimationOptions = [.allowUserInteraction]) {
        self.duration = duration
        self.damping = damping
        self.velocity = velocity
        self.delay = delay
        self.options = options
    }
}

public extension SpringAnimationStyle {
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
