import Combine
import Foundation
import SwiftUI
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
    case display1
    case display2
    case display3
    case heading3
    case heading2
    case heading1
    case body1
    case body2
    case body3
    case label
    case finePrint
    //    case displayXXLShort
    //    case displayXXLLong
    //    case displayXLShort
    //    case displayXLLong
    //    case displayLShort
    //    case displayLLong
    //    case displayMShort
    //    case displayMLong
    //    case displaySShort
    //    case displaySLong
    //    case displayXSShort
    //    case displayXSLong

    case title
    case title1
    case title2
    case title3
    case headline
    case subheadline
    case callout
    case footnote
    case standardSmall  //14
    case badge

    var fontSize: CGFloat {
        switch self {
        case .display1: return 54
        case .display2: return 68
        case .display3: return 84

        case .heading1: return 18
        case .heading2: return 24
        case .heading3: return 32

        case .body1: return 18
        case .body2: return 24
        case .body3: return 32

        case .label: return 14
        case .finePrint: return 12
        //        case .displayXXLShort: return 92
        //        case .displayXXLLong: return 84
        //        case .displayXLShort: return 84
        //        case .displayXLLong: return 76
        //        case .displayLShort: return 76
        //        case .displayLLong: return 68
        //        case .displayMShort: return 68
        //        case .displayMLong: return 54
        //        case .displaySShort: return 48
        //        case .displaySLong: return 32
        //        case .displayXSShort: return 32
        //        case .displayXSLong: return 28
        case .title: return 32
        case .title1: return 28
        case .title2: return 26
        case .title3: return 24
        case .headline: return 17
        case .subheadline: return 15
        case .callout: return 16
        case .footnote: return 14
        case .standardSmall: return 14
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
        case .display1: return .title1
        case .display2: return .title1
        case .display3: return .title1
        case .heading3:
            return .title3
        case .heading2:
            return .title2
        case .heading1:
            return .title1
        case .body1:
            return .body
        case .body2:
            return .body
        case .body3:
            return .body
        case .label:
            return .body
        case .finePrint:
            return .footnote
        //        case .displayXXLShort:
        //            return .largeTitle
        //        case .displayXXLLong:
        //            return .largeTitle
        //        case .displayXLShort:
        //            return .largeTitle
        //        case .displayXLLong:
        //            return .largeTitle
        //        case .displayLShort:
        //            return .largeTitle
        //        case .displayLLong:
        //            return .largeTitle
        //        case .displayMShort:
        //            return .title3
        //        case .displayMLong:
        //            return .title3
        //        case .displaySShort:
        //            return .title2
        //        case .displaySLong:
        //            return .title2
        //        case .displayXSShort:
        //            return .title1
        //        case .displayXSLong:
        //            return .title1
        case .title:
            return .title1
        case .title1:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .footnote:
            return .footnote
        case .standardSmall:
            return .body  //14
        case .subheadline:
            return .body
        case .callout:
            return .body
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
        case .body1:
            return 22 - font.lineHeight
        case .callout:
            return 21 - font.lineHeight
        case .footnote:
            return 18 - font.lineHeight
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
        Text(text).modifier(hFontModifier(style: style ?? defaultStyle ?? .body1))
    }
}
