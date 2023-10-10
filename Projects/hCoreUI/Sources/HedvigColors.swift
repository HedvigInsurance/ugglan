import DynamicColor
import Foundation
import UIKit
import hCore

extension UIColor {
    private enum BrandColorBase {
        static let offWhite = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        static let offBlack = UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
        static let white = UIColor.white
        static let black = UIColor.black
        static let transparent = UIColor.clear
        static let darkGray = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.15)
        static let lightGray = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
        static let tertiaryText = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? BrandColorBase.lightGray : BrandColorBase.darkGray
        })
        static let primaryTextMuted = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? BrandColorBase.lightGray : BrandColorBase.darkGray
        })
        static let secondaryText = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.offBlack
        })
        static let lavender = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.75, green: 0.61, blue: 0.95, alpha: 1.00)
                : UIColor(red: 0.79, green: 0.67, blue: 0.96, alpha: 1.00)
        })
        static var primaryBorder = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.15) : BrandColorBase.grayBorder
        })
        static let grayBorder = UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.12)
        //    static let link = UIColor.tint(.lavenderOne)
        static let caution = UIColor(red: 0.95, green: 0.783, blue: 0.321, alpha: 1)
        static let destructive = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.867, green: 0.153, blue: 0.153, alpha: 1)
                : UIColor(red: 0.886, green: 0.275, blue: 0.275, alpha: 1)
        })
    }

    public enum TypographyColor {
        case primary(state: State)
        //        case secondary(state: State)

        public enum State {
            case negative
            case positive
            case dynamic
            case dynamicReversed
            case matching(_ color: UIColor)
        }

        public static var primary: Self { Self.primary(state: .dynamic) }

        //        public static var secondary: Self { Self.secondary(state: .dynamic) }

        public var positiveColor: UIColor {
            switch self {
            case .primary: return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1)

            //            case .secondary: return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.73)

            }
        }

        public var negativeColor: UIColor {
            switch self {
            case .primary: return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            //            case .secondary: return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.66)

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
            //            case let .secondary(state: state): return color(for: state)
            }
        }
    }

    public static func typographyColor(_ typographyColor: TypographyColor) -> UIColor { typographyColor.color }
}
