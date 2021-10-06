import Foundation
import UIKit
import hCore

extension UIView.ShadowProperties {
    static let embark = UIView.ShadowProperties(
        opacity: 1,
        offset: .init(width: 0, height: 1),
        blurRadius: 1,
        color: .brand(.secondaryShadowColor),
        path: nil,
        radius: 8
    )
}
