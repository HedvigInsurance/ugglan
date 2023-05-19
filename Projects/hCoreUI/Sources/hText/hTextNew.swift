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
    case bodyNew
    case titleNew
    case footnoteNew

    var uifontTextStyleNew: Font {
        switch self {
        case .titleNew:
            return .system(size: 24)
        case .bodyNew:
            return .system(size: 18)
        case .footnoteNew:
            return .system(size: 14)
        }
    }
}

struct hFontModifierNew: ViewModifier {
    public var style: HFontTextStyleNew

    var fontNew: Font {
        FontsNew.fontForNew(style: style)
    }

    var lineSpacingNew: CGFloat {
        switch style {
        case .bodyNew:
            return 23.76
        case .titleNew:
            return 30.24
        case .footnoteNew:
            return 19.6
        default:
            return 0
        }
    }

    func body(content: Content) -> some View {
        content
            .font(fontNew)
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
        Text(text).modifier(hFontModifierNew(style: style ?? defaultStyleNew ?? .bodyNew))
    }
}
