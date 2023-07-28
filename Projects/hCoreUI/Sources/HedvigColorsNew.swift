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
        static let grayScale1000 = UIColor(hexString: "121212")
        static let white = UIColor.white
        static let black = UIColor.black

        static var primaryBorder = UIColor(dynamic: { trait -> UIColor in
            BrandColorBaseNew.grayScale1000.withAlphaComponent(0.07)
        })

    }
    public enum BrandColorNew {
        case primaryBackground(_ negative: Bool = false)
        case secondaryBackground(_ negative: Bool = false)
        case primaryBorderColor
        case primaryText(_ negative: Bool = false)
        case secondaryText
        case messageBackground(_ my: Bool = false)
        public var color: UIColor {
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
            case let .secondaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        BrandColorBaseNew.grayScale1000.withAlphaComponent(0.045)
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    BrandColorBaseNew.grayScale1000.withAlphaComponent(0.045)
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
            case let .messageBackground(my):
                return UIColor(dynamic: { trait -> UIColor in
                    if my {
                        return hSignalColorNew.blueFill
                            .colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color.uiColor()
                    } else {
                        return hFillColorNew.opaqueOne
                            .colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color.uiColor()
                    }
                })
            }
        }
    }

    public static func brandNew(_ color: BrandColorNew) -> UIColor { color.color }
}
