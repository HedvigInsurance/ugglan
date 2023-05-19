import DynamicColor
import Foundation
import UIKit
import hCore

extension UIColor { private enum BrandColorBaseNew {

    static let greyScale25 = UIColor(red: 250, green: 250, blue: 250, alpha: 1)  // #FAFAFA Off-White
    static let greyScale50 = UIColor(red: 245, green: 245, blue: 245, alpha: 0.1)  // #F5F5F5
    static let greyScale100 = UIColor(red: 240, green: 240, blue: 240, alpha: 1)  // #F0F0F0
    static let greyScale200 = UIColor(red: 234, green: 234, blue: 234, alpha: 1)  // #EAEAEA
    static let greyScale300 = UIColor(red: 224, green: 224, blue: 224, alpha: 1)  // #E0E0E0
    static let greyScale400 = UIColor(red: 207, green: 207, blue: 207, alpha: 1)  // #CFCFCF
    static let almostBlack = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
    static let offWhite = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
    static let offBlack = UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
    static let white = UIColor.white
    static let black = UIColor.black
    static let transparent = UIColor.clear
    static let darkGray = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.15)
    static let lightGray = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
    static let tertiaryText = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark ? BrandColorBaseNew.lightGray : BrandColorBaseNew.darkGray
    })
    static let primaryTextMuted = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark ? BrandColorBaseNew.lightGray : BrandColorBaseNew.darkGray
    })
    static let secondaryText = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark ? BrandColorBaseNew.white : BrandColorBaseNew.offBlack
    })
    static let lavender = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.75, green: 0.61, blue: 0.95, alpha: 1.00)
            : UIColor(red: 0.79, green: 0.67, blue: 0.96, alpha: 1.00)
    })
    static var primaryBorder = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.15) : BrandColorBaseNew.grayBorder
    })
    static let grayBorder = UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.12)
    static let caution = UIColor(red: 0.95, green: 0.783, blue: 0.321, alpha: 1)
    static let destructive = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.867, green: 0.153, blue: 0.153, alpha: 1)
            : UIColor(red: 0.886, green: 0.275, blue: 0.275, alpha: 1)
    })
}

private enum GrayscaleNew {
    static let hGray1 = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
    static let hGray5 = UIColor(red: 0.145, green: 0.145, blue: 0.145, alpha: 1)
}

public enum BrandColorNew {
    case primaryBackground(_ negative: Bool = false)
    case secondaryBackground(_ negative: Bool = false)
    case primaryText(_ negative: Bool = false)
    case primaryTextMuted
    case secondaryText
    case tertiaryText
    case primaryTintColor
    case primaryButtonBackgroundColor
    case secondaryButtonBackgroundColor
    case primaryButtonTextColor
    case secondaryButtonTextColor
    case primaryShadowColor
    case secondaryShadowColor
    case regularCaution
    case primaryBorderColor
    case embarkMessageBubble(_ negative: Bool = false)
    case destructive

    var color: UIColor {
        switch self {
        case let .primaryBackground(negative):
            if negative {
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.greyScale50 : BrandColorBaseNew.almostBlack
                })
            }

            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? BrandColorBaseNew.almostBlack : BrandColorBaseNew.greyScale50
            })
        case let .secondaryBackground(negative):
            if negative {
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark
                        ? BrandColorBaseNew.white
                        : BrandColorBaseNew.almostBlack.lighter(amount: 0.10)
                })
            }

            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark
                    ? BrandColorBaseNew.almostBlack.lighter(amount: 0.10) : BrandColorBaseNew.white
            })
        case let .primaryText(negative):
            if negative {
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBaseNew.black : BrandColorBaseNew.white
                })
            }

            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? BrandColorBaseNew.white : BrandColorBaseNew.black
            })
        case .secondaryText: return BrandColorBaseNew.secondaryText
        case .primaryTintColor:
            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? BrandColorBaseNew.white : BrandColorBaseNew.black
            })
        case .primaryButtonBackgroundColor: return BrandColorBaseNew.lavender
        case .primaryButtonTextColor: return BrandColorBaseNew.black
        case .secondaryButtonBackgroundColor:
            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? BrandColorBaseNew.lavender : BrandColorBaseNew.black
            })
        case .secondaryButtonTextColor:
            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? BrandColorBaseNew.black : BrandColorBaseNew.white
            })
        case .primaryShadowColor:
            return UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? BrandColorBaseNew.transparent : BrandColorBaseNew.darkGray
            })
        case .tertiaryText: return BrandColorBaseNew.tertiaryText
        case .primaryTextMuted: return BrandColorBaseNew.primaryTextMuted
        case .regularCaution: return BrandColorBaseNew.caution
        case .primaryBorderColor: return BrandColorBaseNew.primaryBorder
        //        case .link: return BrandColorBaseNew.link
        case .destructive: return BrandColorBaseNew.destructive
        case .secondaryShadowColor: return UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        case let .embarkMessageBubble(negative):
            if negative { return BrandColorBaseNew.lavender }

            return UIColor { (trait) -> UIColor in
                trait.userInterfaceStyle == .dark ? GrayscaleNew.hGray5 : GrayscaleNew.hGray1
            }
        }
    }
}

public static func brandNew(_ color: BrandColorNew) -> UIColor { color.color }

    public enum TintColorNew {
        case yellowOne
        case yellowTwo
        case lavenderOne
        case lavenderTwo

        var color: UIColor {
            switch self {
            case .yellowOne:
                return UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return #colorLiteral(
                            red: 0.840_170_323_8,
                            green: 0.696_349_918_8,
                            blue: 0.232_509_821_7,
                            alpha: 1
                        )
                    }

                    return #colorLiteral(
                        red: 0.949_019_607_8,
                        green: 0.784_313_725_5,
                        blue: 0.321_568_627_5,
                        alpha: 1
                    )
                })
            case .yellowTwo:
                return UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return #colorLiteral(
                            red: 0.890_196_085,
                            green: 0.725_490_212_4,
                            blue: 0.270_588_249,
                            alpha: 1
                        )
                    }

                    return #colorLiteral(
                        red: 0.980_392_158,
                        green: 0.878_431_379_8,
                        blue: 0.596_078_455_4,
                        alpha: 1
                    )
                })
            case .lavenderOne:
                return UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return #colorLiteral(
                            red: 0.745_098_039_2,
                            green: 0.607_843_137_3,
                            blue: 0.952_941_176_5,
                            alpha: 1
                        )
                    }

                    return #colorLiteral(
                        red: 0.788_235_294_1,
                        green: 0.670_588_235_3,
                        blue: 0.960_784_313_7,
                        alpha: 1
                    )
                })
            case .lavenderTwo:
                return UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return #colorLiteral(
                            red: 0.168_627_451,
                            green: 0.125_490_196_1,
                            blue: 0.231_372_549,
                            alpha: 1
                        )
                    }

                    return #colorLiteral(red: 0.9058823529, green: 0.8392156863, blue: 1, alpha: 1)
                })
            }
        }
    }

    public static func tintNew(_ tint: TintColor) -> UIColor { tint.color }

    public enum GrayscaleColorNew {
        case grayOne
        case grayFive

        var color: UIColor {
            switch self {
            case .grayOne:
                return #colorLiteral(
                    red: 0.917_647_058_8,
                    green: 0.917_647_058_8,
                    blue: 0.917_647_058_8,
                    alpha: 1
                )
            case .grayFive:
                return #colorLiteral(red: 0.1930259168, green: 0.1930313706, blue: 0.19302845, alpha: 1)
            }
        }
    }

    public static func grayscaleNew(_ grayscale: GrayscaleColor) -> UIColor { grayscale.color }

    public enum TypographyColorNew { case primary(state: State)
        case secondary(state: State)
        case tertiary(state: State)
        case quartenary(state: State)
        case link(state: State)
        case destructive(state: State)

        public enum State {
            case negative
            case positive
            case dynamic
            case dynamicReversed
            case matching(_ color: UIColor)
        }

        public static var primary: Self { Self.primary(state: .dynamic) }

        public static var secondary: Self { Self.secondary(state: .dynamic) }

        public static var tertiary: Self { Self.tertiary(state: .dynamic) }

        public static var quartenary: Self { Self.quartenary(state: .dynamic) }

        public static var link: Self { Self.link(state: .dynamic) }

        public static var destructive: Self { Self.destructive(state: .dynamic) }

        public var positiveColor: UIColor {
            switch self {
            case .primary: return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1)

            case .secondary: return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.73)

            case .tertiary: return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.56)

            case .quartenary: return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.34)

            case .link: return UIColor(red: 0.53, green: 0.369, blue: 0.771, alpha: 1)

            case .destructive: return UIColor(red: 0.867, green: 0.153, blue: 0.153, alpha: 1)
            }
        }

        public var negativeColor: UIColor {
            switch self {
            case .primary: return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            case .secondary: return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.66)

            case .tertiary: return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.44)

            case .quartenary: return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.27)

            case .link: return UIColor(red: 0.745, green: 0.608, blue: 0.953, alpha: 1)

            case .destructive: return UIColor(red: 0.886, green: 0.275, blue: 0.275, alpha: 1)
            }
        }

        var dynamicColor: UIColor {
            UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark { return self.negativeColor }

                return self.positiveColor
            })
        }

        var dynamicReversedColor: UIColor {
            UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark { return self.dynamicColor }

                return self.negativeColor
            })
        }

        func color(for state: State) -> UIColor {
            switch state {
            case .dynamic: return dynamicColor
            case .dynamicReversed: return dynamicReversedColor
            case .negative: return negativeColor
            case .positive: return positiveColor
            case let .matching(color):
                return UIColor(dynamic: { _ -> UIColor in
                    color.luminance > 0.3 ? self.positiveColor : self.negativeColor
                })
            }
        }

        var color: UIColor {
            switch self {
            case let .primary(state: state): return color(for: state)
            case let .secondary(state: state): return color(for: state)
            case let .tertiary(state: state): return color(for: state)
            case let .quartenary(state: state): return color(for: state)
            case let .link(state: state): return color(for: state)
            case let .destructive(state: state): return color(for: state)
            }
        }
    }

    public static func typographyColorNew(_ typographyColor: TypographyColor) -> UIColor { typographyColor.color }
}
