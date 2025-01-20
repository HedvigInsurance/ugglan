import SwiftUI

public struct hVStack<Content>: View where Content: View {
    let alignment: HorizontalAlignment
    let defaultSpacing: CGFloat
    let diffSizeSpacing: CGFloat?
    @ViewBuilder private var content: () -> Content
    @Environment(\.sizeCategory) var sizeCategory

    private var finalSpace: CGFloat {
        if sizeCategory == .large {
            return defaultSpacing
        }
        return (diffSizeSpacing ?? defaultSpacing) * HFontTextStyle.body1.multiplier
    }

    public init(
        alignment: HorizontalAlignment,
        spacing: CGFloat,
        diffSpacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content
        self.defaultSpacing = spacing
        self.diffSizeSpacing = diffSpacing
    }
    public var body: some View {
        VStack(alignment: alignment, spacing: finalSpace) {
            content()
        }
    }
}
