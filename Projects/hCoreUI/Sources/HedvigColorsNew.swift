import DynamicColor
import Form
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
        static let grayScale500 = UIColor(hexString: "B4B4B4")
        static let grayScale700 = UIColor(hexString: "707070")
        static let grayScale800 = UIColor(hexString: "505050")
        static let grayScale900 = UIColor(hexString: "303030")
        static let grayScale1000 = UIColor(hexString: "121212")
        static let amber600 = UIColor(hexString: "FFBF00")
        static let amberDark = UIColor(hexString: "E5AC00")
        static let red600 = UIColor(hexString: "FF513A")
        static let redDark = UIColor(hexString: "FF391F")
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
        case secondaryBorderColor
        case primaryText(_ negative: Bool = false)
        case secondaryText
        case messageBackground(_ my: Bool = false)
        case navigationButton
        case chatTimeStamp
        case chatMessage
        case toasterBackground
        case toasterBorder
        case toasterTitle
        case toasterSubtitle
        case chatTextView
        case alert
        case caution

        public var color: UIColor {
            switch self {
            case let .primaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark
                            ? BrandColorBaseNew.grayScale25 : BrandColorBaseNew.grayScale1000
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBaseNew.grayScale1000 : BrandColorBaseNew.grayScale25
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
            case .secondaryBorderColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.grayScale800 : BrandColorBaseNew.grayScale1000.withAlphaComponent(0.07)
                })
            case let .primaryText(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark
                            ? BrandColorBaseNew.grayScale1000 : BrandColorBaseNew.grayScale25
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBaseNew.grayScale25 : BrandColorBaseNew.grayScale1000
                })
            case .secondaryText:
                return UIColor(dynamic: { trait -> UIColor in
                    BrandColorBaseNew.grayScale700
                })
            case let .messageBackground(my):
                return UIColor(dynamic: { trait -> UIColor in
                    if my {
                        return hSignalColor.blueFill
                            .colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color.uiColor()
                    } else {
                        return UIColor(dynamic: { trait -> UIColor in
                            trait.userInterfaceStyle == .dark
                                ? BrandColorBaseNew.grayScale100 : BrandColorBaseNew.grayScale100
                        })
                    }
                })
            case .navigationButton:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBaseNew.white : BrandColorBaseNew.black
                })
            case .chatTimeStamp:
                return UIColor(dynamic: { trait -> UIColor in
                    hTextColor.tertiary.colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color
                        .uiColor()
                })
            case .chatMessage:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.grayScale1000 : BrandColorBaseNew.grayScale1000
                })
            case .toasterBackground:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.greenFill.colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color
                        .uiColor()
                })
            case .toasterBorder:
                return UIColor(dynamic: { trait -> UIColor in
                    hBorderColor.translucentOne.colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                        .color
                        .uiColor()
                })
            case .toasterTitle:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.greenText.colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color
                        .uiColor()
                })
            case .toasterSubtitle:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.greenText.colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base).color
                        .uiColor()
                })
            case .chatTextView:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.grayScale900 : BrandColorBaseNew.grayScale1000.withAlphaComponent(0.045)
                })
            case .caution:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.amberDark : BrandColorBaseNew.amber600
                })
            case .alert:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.redDark : BrandColorBaseNew.red600
                })
            }
        }
        var textStyle: TextStyle {
            TextStyle.default.restyled { (style: inout TextStyle) in
                style.font = font
                style.color = color
                style.adjustsFontForContentSizeCategory = true
            }
        }

        private var font: UIFont {
            switch self {
            case .primaryBackground: return Fonts.fontFor(style: .title1)
            case .secondaryBackground: return Fonts.fontFor(style: .title1)
            case .primaryBorderColor: return Fonts.fontFor(style: .title1)
            case .secondaryBorderColor: return Fonts.fontFor(style: .title1)
            case .primaryText: return Fonts.fontFor(style: .title2)
            case .secondaryText: return Fonts.fontFor(style: .title3)
            case .messageBackground: return Fonts.fontFor(style: .headline)
            case .navigationButton: return Fonts.fontFor(style: .standard)
            case .chatTimeStamp: return Fonts.fontFor(style: .standardExtraSmall)
            case .chatMessage: return Fonts.fontFor(style: .standard)
            case .toasterBackground: return Fonts.fontFor(style: .title1)
            case .toasterBorder: return Fonts.fontFor(style: .body)
            case .toasterTitle: return Fonts.fontFor(style: .standardSmall)
            case .toasterSubtitle: return Fonts.fontFor(style: .standardExtraSmall)
            case .chatTextView: return Fonts.fontFor(style: .standard)
            case .caution: return Fonts.fontFor(style: .standard)
            case .alert: return Fonts.fontFor(style: .standard)
            }
        }
    }

    public static func brandNew(_ color: BrandColorNew) -> UIColor { color.color }

    public static func brandNewStyle(_ color: BrandColorNew) -> TextStyle { color.textStyle }

}
