import Combine
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentDefaultHTextStyle: EnvironmentKey {
    static let defaultValue: UIFont.TextStyle? = nil
}

extension EnvironmentValues {
    public var defaultHTextStyle: UIFont.TextStyle? {
        get { self[EnvironmentDefaultHTextStyle.self] }
        set { self[EnvironmentDefaultHTextStyle.self] = newValue }
    }
}

extension View {
    public func hTextStyle(_ style: UIFont.TextStyle? = nil) -> some View {
        self.environment(\.defaultHTextStyle, style)
    }
}

private struct EnvironmentHButtonWasTappedDate: EnvironmentKey {
    static let defaultValue: Date? = nil
}

extension EnvironmentValues {
    var hButtonWasTappedDate: Date? {
        get { self[EnvironmentHButtonWasTappedDate.self] }
        set { self[EnvironmentHButtonWasTappedDate.self] = newValue }
    }
}

extension String {
    public func hText(_ style: UIFont.TextStyle? = nil) -> hText {
        if let style = style {
            return hCoreUI.hText(self, style: style)
        } else {
            return hCoreUI.hText(self)
        }
    }
}

struct hFontModifier: ViewModifier {
    public var style: UIFont.TextStyle

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
    public var style: UIFont.TextStyle?
    @Environment(\.defaultHTextStyle) var defaultStyle
    @Environment(\.hButtonWasTappedDate) var hButtonWasTappedDate

    public init(
        _ text: String,
        style: UIFont.TextStyle
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
            .onReceive(Just(hButtonWasTappedDate)) { dateTapped in
                guard dateTapped != nil else {
                    return
                }

                if let derivedFromL10n = text.derivedFromL10n {
                    Analytics.track(.buttonClick, properties: ["localizationKey": derivedFromL10n.key])
                } else {
                    Analytics.track(.buttonClick, properties: ["content": text])
                }
            }
    }
}
