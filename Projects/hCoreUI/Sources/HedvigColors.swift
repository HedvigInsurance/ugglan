import DynamicColor
import Foundation
import hCore
import UIKit

public extension UIColor {
    private struct BrandColorBase {
        static let almostBlack = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
        static let offWhite = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        static let offBlack = UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
        static let white = UIColor.white
        static let black = UIColor.black
        static let transparent = UIColor.clear
        static let darkGray = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.15)
        static let lightGray = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
        static let tertiaryText = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                BrandColorBase.lightGray :
                BrandColorBase.darkGray
        })
        static let primaryTextMuted = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                BrandColorBase.lightGray :
                BrandColorBase.darkGray
        })
        static let secondaryText = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                BrandColorBase.white :
                BrandColorBase.offBlack
        })
        static let lavender = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.75, green: 0.61, blue: 0.95, alpha: 1.00) :
                UIColor(red: 0.79, green: 0.67, blue: 0.96, alpha: 1.00)
        })
        static var primaryBorder: UIColor = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.15) : BrandColorBase.grayBorder
        })
        static let grayBorder = UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.12)
        static let link = UIColor(red: 0.53, green: 0.37, blue: 0.77, alpha: 1.00)
        static let caution = UIColor(red: 0.95, green: 0.783, blue: 0.321, alpha: 1)
        static let destructive = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.867, green: 0.153, blue: 0.153, alpha: 1) :
                UIColor(red: 0.886, green: 0.275, blue: 0.275, alpha: 1)
        })
    }

    enum BrandColor {
        case primaryBackground(_ negative: Bool = false)
        case secondaryBackground(_ negative: Bool = false)
        case primaryText(_ negative: Bool = false)
        case primaryTextMuted
        case secondaryText
        case tertiaryText
        case primaryTintColor
        case link
        case primaryButtonBackgroundColor
        case secondaryButtonBackgroundColor
        case primaryButtonTextColor
        case secondaryButtonTextColor
        case primaryShadowColor
        case regularCaution
        case primaryBorderColor
        case destructive

        var color: UIColor {
            switch self {
            case let .primaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBase.offWhite : BrandColorBase.almostBlack
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.almostBlack : BrandColorBase.offWhite
                })
            case let .secondaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.almostBlack.lighter(amount: 0.10)
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.almostBlack.lighter(amount: 0.10) : BrandColorBase.white
                })
            case let .primaryText(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBase.black : BrandColorBase.white
                    })
                }

                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.black
                })
            case .secondaryText:
                return BrandColorBase.secondaryText
            case .primaryTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.black
                })
            case .primaryButtonBackgroundColor:
                return BrandColorBase.lavender
            case .primaryButtonTextColor:
                return BrandColorBase.black
            case .secondaryButtonBackgroundColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.lavender : BrandColorBase.black
                })
            case .secondaryButtonTextColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.black : BrandColorBase.white
                })
            case .primaryShadowColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ?
                        BrandColorBase.transparent :
                        BrandColorBase.darkGray
                })
            case .tertiaryText:
                return BrandColorBase.tertiaryText
            case .primaryTextMuted:
                return BrandColorBase.primaryTextMuted
            case .regularCaution:
                return BrandColorBase.caution
            case .primaryBorderColor:
                return BrandColorBase.primaryBorder
            case .link:
                return BrandColorBase.link
            case .destructive:
                return BrandColorBase.destructive
            }
        }
    }

    static func brand(_ color: BrandColor) -> UIColor {
        color.color
    }

    enum TintColor {
        case yellowOne
        case yellowTwo

        var color: UIColor {
            switch self {
            case .yellowOne:
                return UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0.8401703238, green: 0.6963499188, blue: 0.2325098217, alpha: 1)
                    }

                    return #colorLiteral(red: 0.9490196078, green: 0.7843137255, blue: 0.3215686275, alpha: 1)
                })
            case .yellowTwo:
                return UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0.890196085, green: 0.7254902124, blue: 0.270588249, alpha: 1)
                    }

                    return #colorLiteral(red: 0.980392158, green: 0.8784313798, blue: 0.5960784554, alpha: 1)
                })
            }
        }
    }

    static func tint(_ tint: TintColor) -> UIColor {
        tint.color
    }
}
