//
//  UIColor+DynamicPolyfill.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-07.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    convenience init(dynamic: @escaping (_ trait: UITraitCollection) -> UIColor) {
        if #available(iOS 13, *) {
            self.init(dynamicProvider: dynamic)
            return
        }

        self.init(cgColor: dynamic(UITraitCollection()).cgColor)
    }
}
