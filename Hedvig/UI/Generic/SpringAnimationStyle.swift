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
    var damping: CGFloat
    var stiffness: CGFloat
    var mass: CGFloat
    var delay: TimeInterval

    init(damping: CGFloat, stiffness: CGFloat, mass: CGFloat, delay: TimeInterval) {
        self.damping = damping
        self.stiffness = stiffness
        self.mass = mass
        self.delay = delay
    }
}

extension SpringAnimationStyle {
    static func lightBounce(delay: TimeInterval = 0) -> SpringAnimationStyle {
        return SpringAnimationStyle(
            damping: 30,
            stiffness: 300,
            mass: 0.7,
            delay: delay
        )
    }
}
