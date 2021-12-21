import SwiftUI
import hCore

public struct RaisedCard<Content: View>: View {
    private let content: Content
    private let alignment: HorizontalAlignment
    var action: (() -> Void)?

    public init(
        alignment: HorizontalAlignment = .center,
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.action = action
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(hBackgroundColor.tertiary)
                .hShadow()
        )
    }
}

struct TappableCard_Previews: PreviewProvider {
    static var previews: some View {
        RaisedCard {

        }
    }
}
