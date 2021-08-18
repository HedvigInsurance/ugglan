import Form
import Foundation
import UIKit

extension TextStyle { public enum BrandTextStyle {
    case largeTitle(color: UIColor.TypographyColor)
    case title1(color: UIColor.TypographyColor)
    case title2(color: UIColor.TypographyColor)
    case title3(color: UIColor.TypographyColor)
    case headline(color: UIColor.TypographyColor)
    case subHeadline(color: UIColor.TypographyColor)
    case body(color: UIColor.TypographyColor)
    case callout(color: UIColor.TypographyColor)
    case footnote(color: UIColor.TypographyColor)
    case caption1(color: UIColor.TypographyColor)
    case caption2(color: UIColor.TypographyColor)

    private var color: UIColor {
        switch self {
        case let .largeTitle(color: color): return color.color
        case let .title1(color: color): return color.color
        case let .title2(color: color): return color.color
        case let .title3(color: color): return color.color
        case let .headline(color: color): return color.color
        case let .subHeadline(color: color): return color.color
        case let .body(color: color): return color.color
        case let .callout(color: color): return color.color
        case let .footnote(color: color): return color.color
        case let .caption1(color: color): return color.color
        case let .caption2(color: color): return color.color
        }
    }

    private var font: UIFont {
        switch self {
        case .largeTitle: return Fonts.fontFor(style: .largeTitle)
        case .title1: return Fonts.fontFor(style: .title1)
        case .title2: return Fonts.fontFor(style: .title2)
        case .title3: return Fonts.fontFor(style: .title3)
        case .headline: return Fonts.fontFor(style: .headline)
        case .subHeadline: return Fonts.fontFor(style: .subheadline)
        case .body: return Fonts.fontFor(style: .body)
        case .callout: return Fonts.fontFor(style: .callout)
        case .footnote: return Fonts.fontFor(style: .footnote)
        case .caption1: return Fonts.fontFor(style: .caption1)
        case .caption2: return Fonts.fontFor(style: .caption2)
        }
    }

    var textStyle: TextStyle {
        TextStyle.default.restyled { (style: inout TextStyle) in
            style.font = font
            style.color = color
            style.adjustsFontForContentSizeCategory = true
        }
    }
}

public static func brand(_ brandTextStyle: BrandTextStyle) -> TextStyle { brandTextStyle.textStyle }
}
