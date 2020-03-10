//
//  UIView+Flip.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-26.
//

import Foundation
import UIKit

public extension UIView {
    func flip() {
        let currentRotation = CGFloat(atan2(Double(transform.b), Double(transform.a)))
        let newRotation = currentRotation + CGFloat.pi * 1.0000001
        transform = CGAffineTransform(rotationAngle: newRotation)
    }

    func reFlip() {
        let currentRotation = CGFloat(atan2(Double(transform.b), Double(transform.a)))
        let newRotation = currentRotation + CGFloat.pi * 0.99999999
        transform = CGAffineTransform(rotationAngle: newRotation)
    }
}
