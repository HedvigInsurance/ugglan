import DynamicColor
import Foundation
import UIKit
import hCore

extension UIColor {
    private enum BrandColorBaseNew {
        static let grayScale25 = UIColor(red: 250, green: 250, blue: 250, alpha: 1)  // #FAFAFA Off-White
        static let grayScale50 = UIColor(red: 245, green: 245, blue: 245, alpha: 0.1)  // #F5F5F5
        static let grayScale100 = UIColor(red: 240, green: 240, blue: 240, alpha: 1)  // #F0F0F0
        static let grayScale200 = UIColor(red: 234, green: 234, blue: 234, alpha: 1)  // #EAEAEA
        static let grayScale300 = UIColor(red: 224, green: 224, blue: 224, alpha: 1)  // #E0E0E0
        static let grayScale400 = UIColor(red: 207, green: 207, blue: 207, alpha: 1)  // #CFCFCF
        static let grayScale700 = UIColor(hexString: "727272")

        static var primaryBorder = UIColor(dynamic: { trait -> UIColor in
            BrandColorBaseNew.grayScale25
        })

    }
    public enum BrandColorNew {
        case primaryBackground(_ negative: Bool = false)
        case primaryBorderColor

        var color: UIColor {
            switch self {
            case let .primaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        BrandColorBaseNew.grayScale25
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    BrandColorBaseNew.grayScale25
                })
            case .primaryBorderColor:
                return BrandColorBaseNew.primaryBorder
            }
        }
    }

    public static func brandNew(_ color: BrandColorNew) -> UIColor { color.color }
}
