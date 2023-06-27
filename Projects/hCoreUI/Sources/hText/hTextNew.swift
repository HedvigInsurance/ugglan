import SwiftUI

private struct EnvironmentDefaultHTextStyleNew: EnvironmentKey {
    static let defaultValue: HFontTextStyleNew? = nil
}

extension EnvironmentValues {
    public var defaultHTextStyleNew: HFontTextStyleNew? {
        get { self[EnvironmentDefaultHTextStyleNew.self] }
        set { self[EnvironmentDefaultHTextStyleNew.self] = newValue }
    }
}

extension View {
    public func hTextStyleNew(_ style: HFontTextStyleNew? = nil) -> some View {
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

public enum HFontTextStyleNew {
    case body
    case title1
    case title2
    case title3
    case footnote
    case customTitle

    var uifontTextStyleNew: UIFont {
        switch self {
        case .title1:
            return .systemFont(ofSize: 48)
        case .title2:
            return .systemFont(ofSize: 32)
        case .title3:
            return .systemFont(ofSize: 24)
        case .customTitle:
            return .systemFont(ofSize: 28)
        case .body:
            return .systemFont(ofSize: 18)
        case .footnote:
            return .systemFont(ofSize: 14)
        }
    }

    var uifontLineHeightDifference: CGFloat {
        return self.uifontTextStyleNew.pointSize / 16
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
        case .footnote:
            return 19.6 - fontNew.lineHeight
        default:
            return 0
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
        Text(text).modifier(hFontModifierNew(style: style ?? defaultStyleNew ?? .body))
    }
}
