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
                .padding(.horizontal, .padding6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
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
                textColor: hTextColor.Opaque.negative,
                backgroundColor: hTextColor.Opaque.primary
            )
        }
    }
}
