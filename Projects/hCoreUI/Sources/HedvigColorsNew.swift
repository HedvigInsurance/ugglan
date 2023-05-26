import DynamicColor
import Foundation
import UIKit
import hCore

extension UIColor {
    private enum BrandColorBaseNew {
        static let grayScale25 = UIColor(hexString: "FAFAFA")
        static let grayScale50 = UIColor(hexString: "F5F5F5")
        static let grayScale100 = UIColor(hexString: "F0F0F0")
        static let grayScale200 = UIColor(hexString: "EAEAEA")
        static let grayScale300 = UIColor(hexString: "E0E0E0")
        static let grayScale400 = UIColor(hexString: "CFCFCF")
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
