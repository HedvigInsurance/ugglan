//
//  UIView+FrameWithoutTransform.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-04-18.
//

import Foundation
import UIKit

extension UIView {
    var frameWithoutTransform: CGRect {
        let size = bounds.size
        
        return CGRect(x: center.x - size.width  / 2,
                      y: center.y - size.height / 2,
                      width: size.width,
                      height: size.height)
    }
}
