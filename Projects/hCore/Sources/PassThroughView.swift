//
//  PassThroughView.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-16.
//

import Foundation
import UIKit

public class PassTroughView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        }

        return hitView
    }
}
