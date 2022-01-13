import SwiftUI
import hCoreUI

struct PlaybackView<Content: View>: View {
    private let content: Content

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            content
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hColorScheme(light: hTintColor.lavenderTwo, dark: hTintColor.lavenderOne))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}
