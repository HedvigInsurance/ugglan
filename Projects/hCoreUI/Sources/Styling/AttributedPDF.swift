import Foundation
import SwiftUI
import hCore

@MainActor
public struct AttributedPDF {
    public init() {}

    public func attributedPDFString(for title: String) -> NSAttributedString {
        let schema = ColorScheme(UITraitCollection.current.userInterfaceStyle) ?? .light
        let attributes =
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .body1),
                NSAttributedString.Key.foregroundColor: hTextColor.Opaque.primary.colorFor(schema, .base).color
                    .uiColor(),
            ]

        let baseText = title
        let pdfAddOnText = L10n.documentPdfLabel
        let combined = baseText + " " + pdfAddOnText
        let attributedString = NSMutableAttributedString(string: combined, attributes: attributes)
        let rangeOfPdf = NSRange(location: baseText.count, length: pdfAddOnText.count + 1)
        attributedString.addAttribute(.font, value: Fonts.fontFor(style: .finePrint), range: rangeOfPdf)
        attributedString.addAttribute(.baselineOffset, value: 6, range: rangeOfPdf)
        attributedString.addAttribute(
            .foregroundColor,
            value: hTextColor.Opaque.primary.colorFor(schema, .base).color.uiColor(),
            range: rangeOfPdf
        )
        return attributedString
    }
}
