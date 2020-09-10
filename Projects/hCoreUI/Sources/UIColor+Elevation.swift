//
//  UIColor+Elevation.swift
//  hCoreUI
//
//  Created by sam on 9.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /// create an instance of UIColor that uses elevated colors on UITraitCollection.userInterfaceLevel == .elevated
    public convenience init(base: UIColor, elevated: UIColor) {
        self.init(dynamic: { trait in
            if #available(iOS 13.0, *) {
                return trait.userInterfaceLevel == .elevated ? elevated : base
            } else {
                return base
            }
        })
    }
}
