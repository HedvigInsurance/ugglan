import Foundation
import UIKit

extension UIView {
    public var frameWithoutTransform: CGRect {
        let center = self.center
        let size = bounds.size

        return CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
