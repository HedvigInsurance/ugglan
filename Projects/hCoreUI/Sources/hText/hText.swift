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
    case prominentTitle
    case largeTitle
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

    var uifontTextStyle: UIFont.TextStyle {
        switch self {
        case .prominentTitle:
            return .largeTitle
        case .largeTitle:
            return .largeTitle
        case .title1:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption1:
            return .caption1
        case .caption2:
            return .caption2
        }
    }
}

struct hFontModifier: ViewModifier {
    public var style: HFontTextStyle

    var font: UIFont {
        Fonts.fontFor(style: style)
    }

    var lineSpacing: CGFloat {
        switch style {
        case .largeTitle:
            return 41 - font.lineHeight
        case .title1:
            return 34 - font.lineHeight
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

    func body(content: Content) -> some View {
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
        Text(text).modifier(hFontModifier(style: style ?? defaultStyle ?? .body))
    }
}
