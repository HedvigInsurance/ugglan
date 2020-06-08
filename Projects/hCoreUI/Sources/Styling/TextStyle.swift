//
//  TextStyle.swift
//  CoreUI
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Form
import Foundation

public extension TextStyle {
    enum TypographyColor {
        case primary(state: State)
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
        }

        public static var primary: Self {
            return Self.primary(state: .dynamic)
        }

        public static var secondary: Self {
            return Self.secondary(state: .dynamic)
        }

        public static var tertiary: Self {
            return Self.tertiary(state: .dynamic)
        }

        public static var quartenary: Self {
            return Self.quartenary(state: .dynamic)
        }

        public static var link: Self {
            return Self.link(state: .dynamic)
        }

        public static var destructive: Self {
            return Self.destructive(state: .dynamic)
        }

        public var positiveColor: UIColor {
            switch self {
            case .primary:
                return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1)

            case .secondary:
                return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.73)

            case .tertiary:
                return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.56)

            case .quartenary:
                return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0.34)

            case .link:
                return UIColor(red: 0.53, green: 0.369, blue: 0.771, alpha: 1)

            case .destructive:
                return UIColor(red: 0.867, green: 0.153, blue: 0.153, alpha: 1)
            }
        }

        public var negativeColor: UIColor {
            switch self {
            case .primary:
                return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            case .secondary:
                return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.66)

            case .tertiary:
                return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.44)

            case .quartenary:
                return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.27)

            case .link:
                return UIColor(red: 0.745, green: 0.608, blue: 0.953, alpha: 1)

            case .destructive:
                return UIColor(red: 0.886, green: 0.275, blue: 0.275, alpha: 1)
            }
        }

        var dynamicColor: UIColor {
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .light {
                    return self.positiveColor
                }

                return self.negativeColor
            })
        }
        
        var dynamicReversedColor: UIColor {
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .light {
                    return self.negativeColor
                }

                return self.dynamicColor
            })
        }


        func color(for state: State) -> UIColor {
            switch state {
            case .dynamic:
                return dynamicColor
            case .dynamicReversed:
                return dynamicReversedColor
            case .negative:
                return self.negativeColor
            case .positive:
                return self.positiveColor
            }
        }

        var color: UIColor {
            switch self {
            case let .primary(state: state):
                return color(for: state)
            case let .secondary(state: state):
                return color(for: state)
            case let .tertiary(state: state):
                return color(for: state)
            case let .quartenary(state: state):
                return color(for: state)
            case let .link(state: state):
                return color(for: state)
            case let .destructive(state: state):
                return color(for: state)
            }
        }
    }

    enum BrandTextStyle {
        case largeTitle(color: TypographyColor)
        case title1(color: TypographyColor)
        case title2(color: TypographyColor)
        case title3(color: TypographyColor)
        case headline(color: TypographyColor)
        case subHeadline(color: TypographyColor)
        case body(color: TypographyColor)
        case callout(color: TypographyColor)
        case footnote(color: TypographyColor)
        case caption1(color: TypographyColor)
        case caption2(color: TypographyColor)

        private var color: UIColor {
            switch self {
            case let .largeTitle(color: color):
                return color.color
            case let .title1(color: color):
                return color.color
            case let .title2(color: color):
                return color.color
            case let .title3(color: color):
                return color.color
            case let .headline(color: color):
                return color.color
            case let .subHeadline(color: color):
                return color.color
            case let .body(color: color):
                return color.color
            case let .callout(color: color):
                return color.color
            case let .footnote(color: color):
                return color.color
            case let .caption1(color: color):
                return color.color
            case let .caption2(color: color):
                return color.color
            }
        }

        private var font: UIFont {
            switch self {
            case .largeTitle:
                return Fonts.fontFor(style: .largeTitle)
            case .title1:
                return Fonts.fontFor(style: .title1)
            case .title2:
                return Fonts.fontFor(style: .title2)
            case .title3:
                return Fonts.fontFor(style: .title3)
            case .headline:
                return Fonts.fontFor(style: .headline)
            case .subHeadline:
                return Fonts.fontFor(style: .subheadline)
            case .body:
                return Fonts.fontFor(style: .body)
            case .callout:
                return Fonts.fontFor(style: .callout)
            case .footnote:
                return Fonts.fontFor(style: .footnote)
            case .caption1:
                return Fonts.fontFor(style: .caption1)
            case .caption2:
                return Fonts.fontFor(style: .caption2)
            }
        }

        var textStyle: TextStyle {
            return TextStyle.default.restyled { (style: inout TextStyle) in
                style.font = font
                style.color = color
            }
        }
    }

    static func brand(_ brandTextStyle: BrandTextStyle) -> TextStyle {
        brandTextStyle.textStyle
    }
}
