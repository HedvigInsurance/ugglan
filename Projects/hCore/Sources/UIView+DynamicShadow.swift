import Flow
import Foundation
import UIKit

public extension UIView {
    struct ShadowProperties {
        public init(
            opacity: Float?,
            offset: CGSize?,
            radius: CGFloat?,
            color: UIColor?,
            path: CGPath?
        ) {
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
            self.color = color
            self.path = path
        }

        let opacity: Float?
        let offset: CGSize?
        let radius: CGFloat?
        let color: UIColor?
        let path: CGPath?
    }

    func applyShadow(_ dynamic: @escaping (_ trait: UITraitCollection) -> ShadowProperties) -> Disposable {
        traitCollectionSignal.atOnce().with(weak: self).onValue { trait, `self` in
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
