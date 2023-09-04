import Combine
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentDefaultHTextStyle: EnvironmentKey {
    static let defaultValue: HFontTextStyle? = nil
}

extension EnvironmentValues {
    public var defaultHTextStyle: HFontTextStyle? {
        get { self[EnvironmentDefaultHTextStyle.self] }
        set { self[EnvironmentDefaultHTextStyle.self] = newValue }
    }
}

extension View {
    public func hTextStyle(_ style: HFontTextStyle? = nil) -> some View {
        self.environment(\.defaultHTextStyle, style)
    }
}

extension String {
    public func hText(_ style: HFontTextStyle? = nil) -> hText {
        if let style = style {
            return hCoreUI.hText(self, style: style)
        } else {
            return hCoreUI.hText(self)
        }
    }
}

public enum HFontTextStyle {
    case title
    case title1
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption1
    case caption2
    case standardExtraSmall  //12
    case standardSmall  //14
    case standard  //18
    case standardLarge  //24
    case standardExtraLarge  //32
    case standardExtraExtraLarge  //48
    case badge

    var fontSize: CGFloat {
        switch self {
        case .title: return 32
        case .title1: return 28
        case .title2: return 26
        case .title3: return 24
        case .headline: return 17
        case .subheadline: return 15
        case .body: return 17
        case .callout: return 16
        case .footnote: return 14
        case .caption1: return 12
        case .caption2: return 11
        case .standardExtraSmall: return 12
        case .standardSmall: return 14
        case .standard: return 18
        case .standardLarge: return 24
        case .standardExtraLarge: return 32
        case .standardExtraExtraLarge: return 48
        case .badge: return 42
        }
    }

    var multiplier: CGFloat {
        let sizeMultiplier: CGFloat = {
            if UITraitCollection.current.preferredContentSizeCategory != .large {
                let defaultDescriptor = UIFontDescriptor.preferredFontDescriptor(
                    withTextStyle: uifontTextStyle,
                    compatibleWith: .current
                )

                let normalSizeDesciptor = UIFontDescriptor.preferredFontDescriptor(
                    withTextStyle: uifontTextStyle,
                    compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
                )
                return defaultDescriptor.pointSize / normalSizeDesciptor.pointSize
            }
            return 1
        }()
        return sizeMultiplier
    }

    private var uifontTextStyle: UIFont.TextStyle {
        switch self {
        case .title:
            return .title1
        case .title1:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .body:
            return .body
        case .headline:
            return .headline
        case .footnote:
            return .footnote
        case .standardExtraSmall:
            return .body  //12
        case .standardSmall:
            return .body  //14
        case .standard:
            return .body  //18
        case .standardLarge:
            return .body  //24
        case .standardExtraLarge:
            return .body  //32
        case .standardExtraExtraLarge:
            return .body  //48
        case .subheadline:
            return .body
        case .callout:
            return .body
        case .caption1:
            return .footnote
        case .caption2:
            return .footnote
        case .badge:
            return .title1
        }
    }
}

public struct hFontModifier: ViewModifier {
    public var style: HFontTextStyle

    public init(style: HFontTextStyle) {
        self.style = style
    }
    var font: UIFont {
        Fonts.fontFor(style: style)
    }

    var lineSpacing: CGFloat {
        switch style {
        //        case .largeTitle:
        //            return 41 - font.lineHeight
        case .title1:
            return 32 - font.lineHeight
        case .title2:
            return 28 - font.lineHeight
        case .title3:
            return 24 - font.lineHeight
        case .headline:
            return 22 - font.lineHeight
        case .subheadline:
            return 20 - font.lineHeight
        case .body:
            return 22 - font.lineHeight
        case .callout:
            return 21 - font.lineHeight
        case .footnote:
            return 18 - font.lineHeight
        case .caption1:
            return 16 - font.lineHeight
        case .caption2:
            return 14 - font.lineHeight
        default:
            return 0
        }
    }

    public func body(content: Content) -> some View {
        content.font(Font(font))
            .lineSpacing(lineSpacing)
    }
}

public struct hText: View {
    public var text: String
    public var style: HFontTextStyle?
    @Environment(\.defaultHTextStyle) var defaultStyle

    public init(
        _ text: String,
        style: HFontTextStyle
    ) {
        self.text = text
        self.style = style
    }

    public init(
        _ text: String
    ) {
        self.text = text
        self.style = nil
    }

    public var body: some View {
        Text(text).modifier(hFontModifier(style: style ?? defaultStyle ?? .standard))
    }
}
