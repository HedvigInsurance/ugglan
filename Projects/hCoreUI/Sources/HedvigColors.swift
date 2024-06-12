import DynamicColor
import Form
import Foundation
import SwiftUI
import hCore

extension UIColor {
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

        static var primaryBorder = UIColor(dynamic: { trait -> UIColor in
            BrandColorBase.grayScale1000.withAlphaComponent(0.07)
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
        case chatMessageImportant
        case toasterBackground
        case toasterBorder
        case toasterTitle
        case toasterSubtitle
        case chatTextView
        case alert
        case caution
        case adyenWebViewBg
        case adyenWebViewText
        case datePickerSelectionColor
        case opaqueFillOne

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
                    return UIColor(dynamic: { trait -> UIColor in
                        BrandColorBase.grayScale1000.withAlphaComponent(0.045)
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    BrandColorBase.grayScale1000.withAlphaComponent(0.045)
                })
            case .primaryBorderColor:
                return BrandColorBase.primaryBorder
            case .secondaryBorderColor:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale800 : BrandColorBase.grayScale1000.withAlphaComponent(0.07)
                })
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
                return UIColor(dynamic: { trait -> UIColor in
                    BrandColorBase.grayScale700
                })
            case let .messageBackground(my):
                return UIColor(dynamic: { trait -> UIColor in
                    if my {
                        return hSignalColor.Blue.fill
                            .colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base).color
                            .uiColor()
                    } else {
                        return UIColor(dynamic: { trait -> UIColor in
                            style ?? trait.userInterfaceStyle == .dark
                                ? BrandColorBase.grayScale100 : BrandColorBase.grayScale100
                        })
                    }
                })
            case .navigationButton:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.black
                })
            case .chatTimeStamp:
                return UIColor(dynamic: { trait -> UIColor in
                    hTextColor.Opaque.tertiary
                        .colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                        .color
                        .uiColor()
                })
            case .chatMessage:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale1000 : BrandColorBase.grayScale1000
                })
            case .chatMessageImportant:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.Blue.element
                        .colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base).color
                        .uiColor()
                })
            case .toasterBackground:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.Green.fill.colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                        .color
                        .uiColor()
                })
            case .toasterBorder:
                return UIColor(dynamic: { trait -> UIColor in
                    hBorderColor.primary
                        .colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                        .color
                        .uiColor()
                })
            case .toasterTitle:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.Green.text.colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                        .color
                        .uiColor()
                })
            case .toasterSubtitle:
                return UIColor(dynamic: { trait -> UIColor in
                    hSignalColor.Green.text.colorFor(style ?? trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                        .color
                        .uiColor()
                })
            case .chatTextView:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale900 : BrandColorBase.grayScale1000.withAlphaComponent(0.045)
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
            case .adyenWebViewBg:
                return BrandColorBase.grayScale25
            case .adyenWebViewText:
                return BrandColorBase.grayScale1000
            case .opaqueFillOne:
                return UIColor(dynamic: { trait -> UIColor in
                    style ?? trait.userInterfaceStyle == .dark
                        ? BrandColorBase.grayScale100 : BrandColorBase.grayScale900
                })
            }
        }
        var color: UIColor {
            return self.color(with: nil)
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
            case .primaryBackground: return Fonts.fontFor(style: .heading3)
            case .secondaryBackground: return Fonts.fontFor(style: .heading3)
            case .primaryBorderColor: return Fonts.fontFor(style: .heading3)
            case .secondaryBorderColor: return Fonts.fontFor(style: .heading3)
            case .primaryText: return Fonts.fontFor(style: .title2)
            case .secondaryText: return Fonts.fontFor(style: .title3)
            case .messageBackground: return Fonts.fontFor(style: .headline)
            case .navigationButton: return Fonts.fontFor(style: .body1)
            case .chatTimeStamp: return Fonts.fontFor(style: .finePrint)
            case .chatMessage, .chatMessageImportant: return Fonts.fontFor(style: .body1)
            case .toasterBackground: return Fonts.fontFor(style: .heading3)
            case .toasterBorder: return Fonts.fontFor(style: .body1)
            case .toasterTitle: return Fonts.fontFor(style: .standardSmall)
            case .toasterSubtitle: return Fonts.fontFor(style: .finePrint)
            case .chatTextView: return Fonts.fontFor(style: .body1)
            case .caution: return Fonts.fontFor(style: .body1)
            case .alert: return Fonts.fontFor(style: .body1)
            case .adyenWebViewBg, .adyenWebViewText: return Fonts.fontFor(style: .body1)
            case .datePickerSelectionColor: return Fonts.fontFor(style: .body1)
            case .opaqueFillOne: return Fonts.fontFor(style: .body1)
            }
        }
    }

    public static func brand(_ color: BrandColorNew, style: UIUserInterfaceStyle? = nil) -> UIColor {
        color.color(with: style)
    }

    public static func brandStyle(_ color: BrandColorNew) -> TextStyle { color.textStyle }

}
