import SwiftUI

public struct hVStack<Content>: View where Content: View {
    let alignment: HorizontalAlignment
    let defaultSpacing: CGFloat
    @ViewBuilder private var content: () -> Content
    @Environment(\.sizeCategory) var sizeCategory

    private var finalSpace: CGFloat {
        if sizeCategory == .large {
            return defaultSpacing
        }
        return defaultSpacing * HFontTextStyle.body1.multiplier
    }

    public init(
        alignment: HorizontalAlignment,
        spacing: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content
        self.defaultSpacing = spacing
    }
    public var body: some View {
        VStack(alignment: alignment, spacing: finalSpace) {
            content()
        }
    }
}
