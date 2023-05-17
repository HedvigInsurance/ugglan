import Combine
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentDefaultHTextStyleNew: EnvironmentKey {
    static let defaultValue: HFontTextStyleNew? = nil
}

extension EnvironmentValues {
    public var defaultHTextStyleNew: HFontTextStyleNew? {
        get { self[EnvironmentDefaultHTextStyleNew.self] }
        set { self[EnvironmentDefaultHTextStyle.self] = newValue }
    }
}

extension View {
    public func hTextStyleNew(_ style: HFontTextStyleNew? = nil) -> some View {
        self.environment(\.defaultHTextStyleNew, style)
    }
}

extension String {
    public func hText(_ style: HFontTextStyleNew? = nil) -> hText {
        if let style = style {
            return hCoreUI.hText(self, style: style)
        } else {
            return hCoreUI.hText(self)
        }
    }
}

public enum HFontTextStyleNew {
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
            return .prominentTitle
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
