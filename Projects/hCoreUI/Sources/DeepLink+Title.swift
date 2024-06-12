import Form
import Foundation
import SwiftUI
import hCore

extension DeepLink {
    public func title(displayText: String) -> AttributedString {
        let schema: ColorScheme = .light
        let attributes = AttributeContainer(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .body1),
                NSAttributedString.Key.foregroundColor: hTextColor.Opaque.primary.colorFor(schema, .base).color
                    .uiColor(),
            ]
        )
        let wholeText = wholeText(displayText: displayText).replacingOccurrences(of: displayText, with: "")
        var result = AttributedString(wholeText, attributes: attributes)

        let deeplinkAttributes = AttributeContainer(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .body1),
                NSAttributedString.Key.foregroundColor: hSignalColor.Blue.element.colorFor(schema, .base).color
                    .uiColor(),
            ]
        )
        var deepLinkText = AttributedString(displayText, attributes: deeplinkAttributes)
        result.append(deepLinkText)
        return result
    }
}
