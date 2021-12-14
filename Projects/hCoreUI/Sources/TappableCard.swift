import SwiftUI
import hCore

public struct TappableCard<Content: View>: View {
    private let content: Content
    var action: (() -> Void)?

    public init(
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content()
    }

    public var body: some View {
        VStack {
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
        TappableCard {

        }
    }
}
