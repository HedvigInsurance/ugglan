//
//  UIView+DynamicShadow.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Flow
import Foundation
import UIKit

extension UIView {
    public struct ShadowProperties {
        public let opacity: Float?
        public let offset: CGSize?
        public let radius: CGFloat?
        public let color: UIColor?
        public let path: CGPath?
        
        public init(opacity: Float?, offset: CGSize?, radius: CGFloat?, color: UIColor?, path: CGPath?) {
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
            self.color = color
            self.path = path
        }
    }

    public func applyShadow(_ dynamic: @escaping (_ trait: UITraitCollection) -> ShadowProperties) -> Disposable {
        return traitCollectionSignal.atOnce().with(weak: self).onValue { trait, `self` in
            let properties = dynamic(trait)

            if let opacity = properties.opacity {
                self.layer.shadowOpacity = opacity
            }

            if let color = properties.color {
                self.layer.shadowColor = color.cgColor
            }

            if let offset = properties.offset {
                self.layer.shadowOffset = offset
            }

            if let radius = properties.radius {
                self.layer.shadowRadius = radius
            }

            if let path = properties.path {
                self.layer.shadowPath = path
            }
        }
    }
}
