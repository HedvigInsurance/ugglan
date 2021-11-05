import SwiftUI

public enum PillStyle {
    case outline
    case fill
}

public struct hPillOutline: View {
    public init(
        text: String
    ) {
        self.text = text
    }

    public let text: String

    public var body: some View {
        hText(text, style: .caption2)
            .modifier(PillModifier())
    }

    struct PillModifier: ViewModifier {
        @SwiftUI.Environment(\.colorScheme) var colorScheme

        func body(content: Content) -> some View {
            if colorScheme == .light {
                content
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .stroke(hLabelColor.primary, lineWidth: 1.0)
                    )
            } else {
                content
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .stroke(hLabelColor.primary, lineWidth: 1.0)
                    )
            }
        }
    }
}

public struct hPillFill<T: hColor>: View {
    public init(
        text: String,
        backgroundColor: T
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
    }

    public let text: String
    public let backgroundColor: T

    public var body: some View {
        hText(text, style: .caption2)
            .modifier(PillModifier(backgroundColor: backgroundColor))
    }

    struct PillModifier: ViewModifier {
        let backgroundColor: T

        func body(content: Content) -> some View {
            content
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: .smallCornerRadius)
                        .fill(backgroundColor)
                )
        }
    }
}
