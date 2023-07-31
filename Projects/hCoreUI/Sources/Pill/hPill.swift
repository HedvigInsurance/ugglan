import SwiftUI

public struct hPillFill<T: hColor, L: hColor>: View {
    public init(
        text: String,
        textColor: L,
        backgroundColor: T
    ) {
        self.text = text
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    public let text: String
    public let textColor: L
    public let backgroundColor: T

    public var body: some View {
        hText(text, style: .standardSmall)
            .foregroundColor(textColor)
            .modifier(PillModifier(backgroundColor: backgroundColor))
    }

    struct PillModifier: ViewModifier {
        let backgroundColor: T

        func body(content: Content) -> some View {
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .fill(backgroundColor)
                )
        }
    }
}

struct ClaimStatus_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            hPillFill(
                text: "TEXT",
                textColor: hLabelColor.primary.inverted,
                backgroundColor: hLabelColor.primary
            )
        }
    }
}
