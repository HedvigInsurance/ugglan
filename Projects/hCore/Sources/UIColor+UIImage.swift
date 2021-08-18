import Foundation
import UIKit

extension UIColor {
    public func asImage(_ size: CGSize = CGSize(width: 1, height: 1 / UIScreen.main.scale)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        setFill()
        ctx?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
