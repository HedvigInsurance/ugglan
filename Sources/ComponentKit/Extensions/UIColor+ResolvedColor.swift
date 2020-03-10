//
//  UIColor+ResolvedColor.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Foundation
import UIKit

extension UIColor {
    public func resolvedColorOrFallback(with: UITraitCollection) -> UIColor {
        if #available(iOS 13, *) {
            return resolvedColor(with: with)
        }

        return self
    }
}
