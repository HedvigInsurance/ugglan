//
//  UIColor+DynamicPolyfill.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-08-27.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(dynamic: @escaping (_ trait: UITraitCollection) -> UIColor) {
        if #available(iOS 13, *) {
            self.init(dynamicProvider: dynamic)
            return
        }
        
        self.init(cgColor: dynamic(UITraitCollection()).cgColor)
    }
}
