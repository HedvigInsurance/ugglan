import SwiftUI
import hCore
import hCoreUI

public struct Story: Identifiable, Equatable {
    public let id: String
    let title: String?
    let startText: String
    let restOfTheText: String
    let imageUrl: URL
    let mimeType: MimeType

    public init(
        id: String,
        title: String?,
        startText: String,
        restOfTheText: String,
        imageUrl: URL,
        mimeType: MimeType
    ) {
        self.id = id
        self.title = title
        self.startText = startText
        self.restOfTheText = restOfTheText
        self.imageUrl = imageUrl
        self.mimeType = mimeType
    }

    @MainActor
    func getAttributedText(schema: ColorScheme) -> AttributedString {
        let colorSchemeType: SwiftUI.ColorScheme = schema == .light ? .light : .dark

        var startText = AttributedString(startText)
        startText.foregroundColor = hTextColor.Opaque.primary.colorFor(colorSchemeType, .base).color
        startText.font = Fonts.fontFor(style: .body2)

        var subtitleText = AttributedString(" " + restOfTheText)
        subtitleText.foregroundColor = hTextColor.Opaque.secondary.colorFor(colorSchemeType, .base).color
        subtitleText.font = Fonts.fontFor(style: .body2)

        return startText + subtitleText
    }
}
