import SwiftUI
import hCoreUI

private let sheetCornerRadius: CGFloat = 32

struct HomeSheetContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            ScrollView { content }
                .padding(.top, .padding8)
        }
        .frame(maxWidth: .infinity)
        .background(
            hRoundedRectangle(cornerRadius: sheetCornerRadius, corners: [.topLeft, .topRight])
                .fill(hBackgroundColor.primary)
                .hShadow(type: .light)
        )
    }

    private var grabber: some View {
        Capsule()
            .fill(hSurfaceColor.Opaque.secondary)
            .frame(width: 40, height: 4)
            .padding(.vertical, .padding4)
            .accessibilityHidden(true)
    }
}

#Preview {
    HomeSheetContainer {
        VStack(spacing: 8) {
            hText("Top content")
            hButton(.medium, .primary, content: .init(title: "Button")) {}
            hText("Buttom content")
        }
    }
}
