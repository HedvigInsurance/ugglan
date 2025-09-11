import Combine
import Foundation
import SwiftUI
import hCore

@MainActor
private struct EnvironmentDefaultHTextStyle: @preconcurrency EnvironmentKey {
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
        environment(\.defaultHTextStyle, style)
    }
}

@MainActor
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

    case heading1
    case heading2
    case heading3

    case body1
    case body2
    case body3

    case label
    case finePrint
    case tabBar

    case displayXXLShort
    case displayXXLLong

    case displayXLShort
    case displayXLLong

    case displayLShort
    case displayLLong

    case displayMShort
    case displayMLong

    case displaySShort
    case displaySLong

    case displayXSShort
    case displayXSLong

    public var fontSize: CGFloat {
        switch self {
        // Standard
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
        case .tabBar: return 10
        // Big
        case .displayXXLShort: return 92
        case .displayXXLLong: return 84
        case .displayXLShort: return 84
        case .displayXLLong: return 76
        case .displayLShort: return 76
        case .displayLLong: return 68
        case .displayMShort: return 68
        case .displayMLong: return 54
        case .displaySShort: return 48
        case .displaySLong: return 32
        case .displayXSShort: return 32
        case .displayXSLong: return 28
        }
    }

    public var multiplier: CGFloat {
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
                let multiplier = defaultDescriptor.pointSize / normalSizeDesciptor.pointSize
                return multiplier
            }
            return 1
        }()
        return min(2.5, sizeMultiplier)
    }

    var fontTextStyle: Font.TextStyle {
        switch self {
        case .display1: return .title
        case .display2: return .title
        case .display3: return .title
        case .heading3: return .title3
        case .heading2: return .title2
        case .heading1: return .title
        case .body1: return .body
        case .body2: return .body
        case .body3: return .body
        case .label: return .footnote
        case .finePrint: return .footnote
        case .displayXXLShort: return .largeTitle
        case .displayXXLLong: return .largeTitle
        case .displayXLShort: return .largeTitle
        case .displayXLLong: return .largeTitle
        case .displayLShort: return .largeTitle
        case .displayLLong: return .largeTitle
        case .displayMShort: return .largeTitle
        case .displayMLong: return .largeTitle
        case .displaySShort: return .largeTitle
        case .displaySLong: return .largeTitle
        case .displayXSShort: return .largeTitle
        case .displayXSLong: return .largeTitle
        case .tabBar: return .callout
        }
    }

    private var uifontTextStyle: UIFont.TextStyle {
        switch self {
        case .display1: return .title1
        case .display2: return .title1
        case .display3: return .title1
        case .heading3: return .title3
        case .heading2: return .title2
        case .heading1: return .title1
        case .body1: return .body
        case .body2: return .body
        case .body3: return .body
        case .label: return .footnote
        case .finePrint: return .footnote
        case .displayXXLShort: return .largeTitle
        case .displayXXLLong: return .largeTitle
        case .displayXLShort: return .largeTitle
        case .displayXLLong: return .largeTitle
        case .displayLShort: return .largeTitle
        case .displayLLong: return .largeTitle
        case .displayMShort: return .largeTitle
        case .displayMLong: return .largeTitle
        case .displaySShort: return .largeTitle
        case .displaySLong: return .largeTitle
        case .displayXSShort: return .largeTitle
        case .displayXSLong: return .largeTitle
        case .tabBar: return .callout
        }
    }
}

public struct hFontModifier: ViewModifier {
    public var style: HFontTextStyle
    @Environment(\.hWithoutFontMultiplier) var withoutFontMultiplier
    @SwiftUI.Environment(\.sizeCategory) var sizeCategory

    public init(style: HFontTextStyle) {
        self.style = style
    }

    var font: UIFont {
        Fonts.fontFor(style: style, withoutFontMultipler: withoutFontMultiplier)
    }

    public func body(content: Content) -> some View {
        content
            .font(.custom(font.fontName, size: style.fontSize, relativeTo: style.fontTextStyle))
    }
}

struct hFloatingTextFieldd_Previews: PreviewProvider {
    @State static var value: String = "Ss"
    @State static var error: String?
    static var previews: some View {
        VStack {
            SwiftUI.TextField("Placeholder", text: $value)
                .modifier(hFontModifier(style: .body2))
                .background {
                    GeometryReader { proxy in
                        Color.red
                            .onAppear {
                                print("TOTAL HEIGHT IS \(proxy.size.height)")
                            }
                            .onChange(of: proxy.size) { size in
                                print("TOTAL HEIGHT IS \(size.height)")
                            }
                    }
                }
        }
        .hFieldSize(.large)
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
        style = nil
    }

    public var body: some View {
        Text(text)
            .modifier(hFontModifier(style: style ?? defaultStyle ?? .body1))
    }
}
