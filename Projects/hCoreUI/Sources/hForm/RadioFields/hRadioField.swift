import Combine
import SwiftUI
import hCore

public struct hRadioField<Content: View>: View {
    private let content: Content
    private let id: String
    private var useAnimation: Bool
    @Environment(\.hFieldSize) var size
    @Environment(\.hLeftAlign) var leftAligned
    @Environment(\.isEnabled) var enabled
    @Binding var selected: String?
    @Binding private var error: String?
    @State private var animate = false

    public init(
        id: String,
        content: @escaping () -> Content,
        selected: Binding<String?>,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false
    ) {
        self.id = id
        self.content = content()
        self._selected = selected
        self._error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
    }

    public var body: some View {
        HStack(spacing: 8) {
            //            if let leftView = leftView?(item) {
            //                leftView
            //            }
            if leftAligned {
                hRadioOptionSelectedView(selectedValue: $selected, value: id)
                content
                Spacer()
            } else {
                content
                Spacer()
                hRadioOptionSelectedView(selectedValue: $selected, value: id)
            }
        }
        .padding(.top, size.topPadding)
        .padding(.bottom, size.bottomPadding)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            ImpactGenerator.soft()
            withAnimation(.none) {
                self.selected = id
            }
            if useAnimation {
                self.animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.animate = false
                }
            }
        }
    }
}

struct hRadioField_Previews: PreviewProvider {
    @State static var value: String?
    @State static var error: String?
    static var previews: some View {
        VStack {
            hRadioField(
                id: "id",
                content: {
                    hText("id")
                },
                selected: $value,
                error: $error,
                useAnimation: true
            )
            //            .hLeftAlign
            .disabled(true)
        }
    }
}

extension hFieldSize {
    fileprivate var minHeight: CGFloat {
        switch self {
        case .small:
            return 56
        case .large:
            return 64
        case .medium:
            return 64
        }
    }

    fileprivate var topPadding: CGFloat {
        switch self {
        case .small:
            return 15
        case .large:
            return 16
        case .medium:
            return 19
        }
    }

    fileprivate var bottomPadding: CGFloat {
        topPadding + 2
    }
}
