//
//  Flow+PanGesture.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-17.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIView {
    func panGesture() -> Signal<UIPanGestureRecognizer> {
        let callbacker = Callbacker<UIPanGestureRecognizer>()

        addGestureRecognizer(UIPanGestureRecognizer(handler: { pan in
            callbacker.callAll(with: pan)
        }))

        return callbacker.signal()
    }
}
