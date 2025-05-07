import SwiftUI

struct LargeButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, 15)
            .padding(.bottom, 17)
            .frame(minHeight: .padding56)
            .frame(maxWidth: .infinity)
    }
}

struct MediumButtonModifier: ViewModifier {
    @Environment(\.hButtonTakeFullWidth) var hButtonTakeFullWidth

    func body(content: Content) -> some View {
        content
            .padding(.top, 7)
            .padding(.bottom, 9)
            .padding(.horizontal, .padding16)
            .frame(maxWidth: hButtonTakeFullWidth ? .infinity : nil)
    }
}

struct SmallButtonModifier: ViewModifier {
    @Environment(\.hButtonTakeFullWidth) var hButtonTakeFullWidth
    func body(content: Content) -> some View {
        content
            .padding(.top, 6.5)
            .padding(.bottom, 7.5)
            .frame(minHeight: 32)
            .padding(.horizontal, .padding16)
            .frame(maxWidth: hButtonTakeFullWidth ? .infinity : nil)
    }
}
