//
//  PassThroughWindow.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-16.
//

import Foundation
import UIKit

public class PassTroughWindow: UIWindow {
    public override var canBecomeFirstResponder: Bool {
        false
    }

    public override var canResignFirstResponder: Bool {
        true
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        }

        return hitView
    }
}

public class PassTroughView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        }

        return hitView
    }
}
