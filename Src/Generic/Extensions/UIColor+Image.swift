//
//  UIColor+Image.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-17.
//

import Foundation
import UIKit

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1 / UIScreen.main.scale, height: 1 / UIScreen.main.scale))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx?.fill(CGRect(x: 0, y: 0, width: 1 / UIScreen.main.scale, height: 1 / UIScreen.main.scale))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
