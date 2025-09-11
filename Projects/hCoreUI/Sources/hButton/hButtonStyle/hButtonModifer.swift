import SwiftUI

struct hButtonModifier: ViewModifier {
    @Environment(\.hButtonTakeFullWidth) var hButtonTakeFullWidth
    var size: hButtonSize

    func body(content: Content) -> some View {
        content
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .frame(minHeight: minHeight)
            .frame(maxWidth: (hButtonTakeFullWidth || size == .large) ? .infinity : nil)
            .padding(.horizontal, size == .large ? 0 : .padding16)
    }

    private var topPadding: CGFloat {
        switch size {
        case .large:
            return 15
        case .medium:
            return 7
        case .small:
            return 6.5
        }
    }

    private var bottomPadding: CGFloat {
        switch size {
        case .large:
            return 17
        case .medium:
            return 9
        case .small:
            return 7.5
        }
    }

    private var minHeight: CGFloat? {
        switch size {
        case .large:
            return .padding56
        case .medium:
            return nil
        case .small:
            return .padding32
        }
    }
}

extension View {
    @ViewBuilder
    func buttonSizeModifier(_ size: hButtonSize) -> some View {
        modifier(hButtonModifier(size: size)).environment(\.defaultHTextStyle, size == .small ? .label : .body1)
    }
}
