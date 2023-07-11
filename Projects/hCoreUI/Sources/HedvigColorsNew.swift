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
        static let grayScale700 = UIColor(hexString: "707070")
        static let white = UIColor.white
        static let black = UIColor.black

        static var primaryBorder = UIColor(dynamic: { trait -> UIColor in
            BrandColorBaseNew.grayScale25
        })

    }
    public enum BrandColorNew {
        case primaryBackground(_ negative: Bool = false)
        case primaryBorderColor
        case primaryText(_ negative: Bool = false)
        case secondaryText
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
            case let .primaryText(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBaseNew.black : BrandColorBaseNew.white
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBaseNew.white : BrandColorBaseNew.black
                })
            case .secondaryText:
                return UIColor(dynamic: { trait -> UIColor in
                    BrandColorBaseNew.grayScale700
                })
            }
        }
    }

    public static func brandNew(_ color: BrandColorNew) -> UIColor { color.color }
}
