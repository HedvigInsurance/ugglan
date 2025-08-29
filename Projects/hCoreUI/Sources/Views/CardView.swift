import SwiftUI

public struct CardView<Content: View>: View {
    let content: Content

    public init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content()
    }

    public var body: some View {
        hSection {
            VStack(spacing: 0) {
                content
            }
            .modifier(ChangeViewBackgroundModifier())
        }
        .sectionContainerStyle(.transparent)
    }
}

struct ChangeViewBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(hBackgroundColor.primary)
            .cornerRadius(.cornerRadiusXXL)
            .shadow(color: Color(red: 0.07, green: 0.07, blue: 0.07).opacity(0.05), radius: 5, x: 0, y: 4)
            .shadow(color: Color(red: 0.07, green: 0.07, blue: 0.07).opacity(0.1), radius: 1, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusXXL)
                    .inset(by: 0.5)
                    .stroke(hBorderColor.primary, lineWidth: 1)
            )
    }
}
