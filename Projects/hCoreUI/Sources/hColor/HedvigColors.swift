import DynamicColor
import Foundation
import SwiftUI
import hCore

@MainActor
extension UIColor {
    @MainActor
    private enum BrandColorBase {
        static let grayScale25 = UIColor(hexString: "FAFAFA")
        static let grayScale50 = UIColor(hexString: "F5F5F5")
        static let grayScale100 = UIColor(hexString: "F0F0F0")
        static let grayScale200 = UIColor(hexString: "EAEAEA")
        static let grayScale300 = UIColor(hexString: "E0E0E0")
        static let grayScale400 = UIColor(hexString: "CFCFCF")
        static let grayScale500 = UIColor(hexString: "B4B4B4")
        static let grayScale700 = UIColor(hexString: "707070")
        static let grayScale800 = UIColor(hexString: "505050")
        static let grayScale900 = UIColor(hexString: "303030")
        static let grayScale1000 = UIColor(hexString: "121212")
        static let amber600 = UIColor(hexString: "FFBF00")
        static let amberDark = UIColor(hexString: "E5AC00")
        static let red600 = UIColor(hexString: "FF513A")
        static let redDark = UIColor(hexString: "FF391F")
        static let green200 = UIColor(hexString: "DAEEBD")
        static let white = UIColor.white
        static let black = UIColor.black

        static var primaryBorder = UIColor(dynamic: { _ -> UIColor in
            BrandColorBase.grayScale1000.withAlphaComponent(0.07)
        })
    }

    public enum BrandColorNew {
        case primaryBackground(_ negative: Bool = false)
        case secondaryBackground(_ negative: Bool = false)
        case primaryBorderColor
        case primaryText(_ negative: Bool = false)
        case secondaryText
        case alert
        case caution

        case datePickerSelectionColor

        @MainActor
        func color(with style: UIUserInterfaceStyle?) -> UIColor {
            switch self {
            case let .primaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        style ?? trait.userInterfaceStyle == .dark
                            ? BrandColorBase.grayScale25 : BrandColorBase.grayScale1000
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale1000 : BrandColorBase.grayScale25
                })
            case let .secondaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { _ -> UIColor in
                        BrandColorBase.grayScale1000.withAlphaComponent(0.045)
                    })
                }

                return UIColor(dynamic: { _ -> UIColor in
                    BrandColorBase.grayScale1000.withAlphaComponent(0.045)
                })
            case .primaryBorderColor:
                return BrandColorBase.primaryBorder
            case let .primaryText(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        style ?? trait.userInterfaceStyle == .dark
                            ? BrandColorBase.grayScale1000 : BrandColorBase.grayScale25
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale25 : BrandColorBase.grayScale1000
                })
            case .secondaryText:
                return UIColor(dynamic: { _ -> UIColor in
                    BrandColorBase.grayScale700
                })
            case .caution:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.amberDark : BrandColorBase.amber600
                })
            case .alert:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.redDark : BrandColorBase.red600
                })
            case .datePickerSelectionColor:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale500 : BrandColorBase.grayScale1000
                })
            }
        }
    }

    public static func brand(_ color: BrandColorNew, style: UIUserInterfaceStyle? = nil) -> UIColor {
        color.color(with: style)
    }
}
