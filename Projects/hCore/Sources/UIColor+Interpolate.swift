import Foundation
import UIKit

struct ColorComponents {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
}

extension UIColor {
    func getComponents() -> ColorComponents {
        if cgColor.numberOfComponents == 2 {
            let cc = cgColor.components!
            return ColorComponents(r: cc[0], g: cc[0], b: cc[0], a: cc[1])
        } else {
            let cc = cgColor.components!
            return ColorComponents(r: cc[0], g: cc[1], b: cc[2], a: cc[3])
        }
    }

    public func interpolateColorTo(end: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)

        let c1 = self.getComponents()
        let c2 = end.getComponents()

        let r = c1.r + (c2.r - c1.r) * f
        let g = c1.g + (c2.g - c1.g) * f
        let b = c1.b + (c2.b - c1.b) * f
        let a = c1.a + (c2.a - c1.a) * f

        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }
}
