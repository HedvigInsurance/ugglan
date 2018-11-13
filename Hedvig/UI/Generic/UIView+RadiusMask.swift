//
//  UIView+roundedMask.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-13.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func applyRadiusMaskFor(
        topLeft: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0,
        topRight: CGFloat = 0
    ) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width - topRight, y: 0))
        path.addLine(to: CGPoint(x: topLeft, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: topLeft), controlPoint: .zero)
        path.addLine(to: CGPoint(x: 0, y: bounds.height - bottomLeft))
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft, y: bounds.height),
            controlPoint: CGPoint(x: 0, y: bounds.height)
        )
        path.addLine(to: CGPoint(x: bounds.width - bottomRight, y: bounds.height))
        path.addQuadCurve(
            to: CGPoint(x: bounds.width, y: bounds.height - bottomRight),
            controlPoint: CGPoint(x: bounds.width, y: bounds.height)
        )
        path.addLine(to: CGPoint(x: bounds.width, y: topRight))
        path.addQuadCurve(
            to: CGPoint(x: bounds.width - topRight, y: 0),
            controlPoint: CGPoint(x: bounds.width, y: 0)
        )

        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }
}
