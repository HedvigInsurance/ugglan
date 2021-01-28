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
            path: CGPath?,
            corners: (UIRectCorner, CGFloat)? = (corners: .allCorners, radius: 8)
        ) {
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
            self.color = color
            self.path = path
            self.corners = corners
        }
        
        let opacity: Float?
        let offset: CGSize?
        let radius: CGFloat?
        let color: UIColor?
        let path: CGPath?
        let corners: (corner: UIRectCorner, radius: CGFloat)?
    }
    
    func applyShadow(_ dynamic: @escaping (_ trait: UITraitCollection) -> ShadowProperties) -> Disposable {
        combineLatest(traitCollectionSignal.atOnce().plain(),
                      didLayoutSignal.atOnce()).onValue { (trait, _) in
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
                        
                        if let corners = properties.corners {
                            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners.corner, cornerRadii: CGSize(width: corners.radius, height: corners.radius)).cgPath
                        }
                        self.layer.shouldRasterize = true
                        self.layer.rasterizationScale = UIScreen.main.scale
                      }
        
    }
}
