import Flow
import Foundation
import UIKit

extension UIView {
    public struct ShadowProperties {
        public init(
            opacity: Float?,
            offset: CGSize?,
            blurRadius: CGFloat?,
            color: UIColor?,
            path: CGPath?,
            radius: CGFloat?,
            corners: UIRectCorner = .allCorners,
            shouldRasterize: Bool = false
        ) {
            self.opacity = opacity
            self.offset = offset
            self.blurRadius = blurRadius
            self.color = color
            self.path = path
            self.radius = radius
            self.corners = corners
            self.shouldRasterize = shouldRasterize
        }

        let opacity: Float?
        let offset: CGSize?
        let blurRadius: CGFloat?
        let color: UIColor?
        let path: CGPath?
        let radius: CGFloat?
        let corners: UIRectCorner
        let shouldRasterize: Bool
    }

    public func applyShadow(_ dynamic: @escaping (_ trait: UITraitCollection) -> ShadowProperties) -> Disposable {
        combineLatest(traitCollectionSignal.atOnce().plain(), didLayoutSignal.atOnce())
            .onValue { trait, _ in let properties = dynamic(trait)

                if let opacity = properties.opacity { self.layer.shadowOpacity = opacity }

                if let color = properties.color { self.layer.shadowColor = color.cgColor }

                if let offset = properties.offset { self.layer.shadowOffset = offset }

                if let blurRadius = properties.blurRadius { self.layer.shadowRadius = blurRadius }

                if let radius = properties.radius {
                    self.layer.shadowPath =
                        UIBezierPath(
                            roundedRect: self.bounds,
                            byRoundingCorners: properties.corners,
                            cornerRadii: CGSize(width: radius, height: radius)
                        )
                        .cgPath
                }

                self.layer.shouldRasterize = properties.shouldRasterize
                self.layer.rasterizationScale = UIScreen.main.scale
            }
    }
}
