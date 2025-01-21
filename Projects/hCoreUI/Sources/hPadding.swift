import SwiftUI

extension View {
    public func hPadding(_ edges: Edge.Set = .all, _ length: CGFloat = 16, diffLength: CGFloat? = nil) -> some View {
        self.modifier(hPaddingModifier(edges, length, diffLength))
    }

    public func hPadding(_ length: CGFloat = 16, diffLength: CGFloat? = nil) -> some View {
        self.modifier(hPaddingModifier(.all, length, diffLength))
    }
}

struct hPaddingModifier: ViewModifier {
    let size: CGFloat
    let diffSizeSize: CGFloat?
    let edges: Edge.Set
    @Environment(\.sizeCategory) var sizeCategory

    private var finalSpace: CGFloat {
        if sizeCategory == .large {
            return size
        }
        return (diffSizeSize ?? size) * HFontTextStyle.body1.multiplier
    }
    public init(_ edges: Edge.Set = .all, _ size: CGFloat, _ diffSizeSize: CGFloat?) {
        self.edges = edges
        self.size = size
        self.diffSizeSize = diffSizeSize
    }

    public func body(content: Content) -> some View {
        content.padding(edges, finalSpace)
    }
}
