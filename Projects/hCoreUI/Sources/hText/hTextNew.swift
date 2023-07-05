import SwiftUI

private struct EnvironmentDefaultHTextStyleNew: EnvironmentKey {
    static let defaultValue: HFontTextStyle? = nil
}

extension EnvironmentValues {
    public var defaultHTextStyleNew: HFontTextStyle? {
        get { self[EnvironmentDefaultHTextStyleNew.self] }
        set { self[EnvironmentDefaultHTextStyleNew.self] = newValue }
    }
}

extension View {
    public func hTextStyleNew(_ style: HFontTextStyle? = nil) -> some View {
        self.environment(\.defaultHTextStyleNew, style)
    }
}

extension String {
    public func hTextNew(_ style: HFontTextStyleNew? = nil) -> hTextNew {
        if let style = style {
            return hCoreUI.hTextNew(self, style: style)
        } else {
            return hCoreUI.hTextNew(self)
        }
    }
}

public enum HFontTextStyleNew: CaseIterable {
    case body
    case title1
    case title2
    case title3
    case footnote
    case customTitle
    case headline

    var fontSize: CGFloat {
        let sizeMultiplier: CGFloat = {
            if UITraitCollection.current.preferredContentSizeCategory != .large {
                let defaultDescriptor = UIFontDescriptor.preferredFontDescriptor(
                    withTextStyle: uifontTextStyle,
                    compatibleWith: .current
                )
                return defaultDescriptor.pointSize / defaultSystemSize
            }
            return 1
        }()
        switch self {
        case .title1:
            return 48 * sizeMultiplier
        case .title2:
            return 32 * sizeMultiplier
        case .title3:
            return 24 * sizeMultiplier
        case .customTitle:
            return 28 * sizeMultiplier
        case .body:
            return 18 * sizeMultiplier
        case .headline:
            return 18 * sizeMultiplier
        case .footnote:
            return 14 * sizeMultiplier
        }
    }

    private var uifontTextStyle: UIFont.TextStyle {
        switch self {
        case .title1:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .customTitle:
            return .title3
        case .body:
            return .body
        case .headline:
            return .headline
        case .footnote:
            return .footnote
        }
    }

    private var defaultSystemSize: CGFloat {
        switch self {
        case .title1:
            return 28
        case .title2:
            return 22
        case .title3:
            return 20
        case .customTitle:
            return 22
        case .body:
            return 17
        case .headline:
            return 17
        case .footnote:
            return 13
        }
    }

    var uifontLineHeightDifference: CGFloat {
        return self.fontSize / 16
    }
}

struct hFontModifierNew: ViewModifier {
    public var style: HFontTextStyleNew

    var fontNew: UIFont {
        FontsNew.fontForNew(style: style)
    }

    var lineSpacingNew: CGFloat {
        switch style {
        case .title1:
            return 60.48 - fontNew.lineHeight
        case .title2:
            return 40.32 - fontNew.lineHeight
        case .title3:
            return 30.24 - fontNew.lineHeight
        case .body:
            return 23.76 - fontNew.lineHeight
        case .headline:
            return 23.76 - fontNew.lineHeight
        case .footnote:
            return 19.6 - fontNew.lineHeight
        case .customTitle:
            return 33.6 - fontNew.lineHeight
        }
    }

    func body(content: Content) -> some View {
        content.font(Font(fontNew))
            .lineSpacing(lineSpacingNew)
    }
}

public struct hTextNew: View {
    public var text: String
    public var style: HFontTextStyleNew?
    @Environment(\.defaultHTextStyleNew) var defaultStyleNew

    public init(
        _ text: String,
        style: HFontTextStyleNew
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
        Text(text).modifier(hFontModifierNew(style: style ?? .body))
    }
}
