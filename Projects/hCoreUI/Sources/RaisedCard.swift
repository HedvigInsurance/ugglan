import SwiftUI
import hCore

public struct RaisedCard<Content: View>: View {
    private let content: Content
    private let alignment: HorizontalAlignment

    public init(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(hBackgroundColorNew.primary)
                .hShadow()
        )
    }
}

struct RaisedCard_Previews: PreviewProvider {
    static var previews: some View {
        RaisedCard {

        }
    }
}
