//
//  PanDirectionGestureRecognizer.swift
//  hedvig
//
//  Created by Sam Pettersson on 2019-06-27.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

enum PanDirection {
    case vertical
    case horizontal
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    let direction: PanDirection

    init(direction: PanDirection) {
        self.direction = direction
        super.init(target: nil, action: nil)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}
