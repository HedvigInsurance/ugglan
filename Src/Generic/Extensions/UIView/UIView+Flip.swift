//
//  UIView+Flip.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-26.
//

import Foundation
import UIKit

extension UIView {
    func flip() {
        let currentRotation = CGFloat(atan2(Double(self.transform.b), Double(self.transform.a)))
        print(currentRotation)
        let newRotation = currentRotation + CGFloat.pi * 1.0000001
        self.transform = CGAffineTransform.init(rotationAngle: newRotation)
    }
    
    func reFlip() {
        let currentRotation = CGFloat(atan2(Double(self.transform.b), Double(self.transform.a)))
        let newRotation = currentRotation + CGFloat.pi * 0.99999999
        self.transform = CGAffineTransform.init(rotationAngle: newRotation)
    }
}
