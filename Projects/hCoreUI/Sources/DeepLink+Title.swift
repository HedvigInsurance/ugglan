import Form
import Foundation
import SwiftUI
import UIKit
import hCore

extension DeepLink {
    public func title(displayText: String) -> NSMutableAttributedString {

        let wholeText = wholeText(displayText: displayText)

        let attributedText = NSMutableAttributedString(
            styledText: StyledText(
                text: wholeText,
                style: UIColor.brandStyle(.chatMessage)
            )
        )
        let range = (wholeText as NSString).range(of: displayText)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.brandStyle(.chatMessageImportant).color,
            range: range
        )
        return attributedText
    }

    @available(iOS 15, *)
    public func title(displayText: String) -> AttributedString {
        let schema: ColorScheme = .light
        let attributes = AttributeContainer(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .standard),
                NSAttributedString.Key.foregroundColor: hTextColor.primary.colorFor(schema, .base).color.uiColor(),
            ]
        )
        let wholeText = wholeText(displayText: displayText).replacingOccurrences(of: displayText, with: "")
        var result = AttributedString(wholeText, attributes: attributes)

        let deeplinkAttributes = AttributeContainer(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .standard),
                NSAttributedString.Key.foregroundColor: hSignalColor.blueElement.colorFor(schema, .base).color
                    .uiColor(),
            ]
        )
        var deepLinkText = AttributedString(displayText, attributes: deeplinkAttributes)
        result.append(deepLinkText)
        return result
    }
}
