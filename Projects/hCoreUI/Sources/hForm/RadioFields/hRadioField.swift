import Combine
import SwiftUI
import hCore

public struct hRadioField<Content: View>: View {
    private let content: Content
    private let id: String
    private var useAnimation: Bool
    @Environment(\.hFieldSize) var size
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
        HStack(spacing: 0) {
            content
            Spacer()
            Circle()
                .strokeBorder(
                    RadioFieldsColors().getBorderColor(isSelected: id == selected),
                    lineWidth: id == selected ? 0 : 1.5
                )
                .background(Circle().foregroundColor(RadioFieldsColors().getFillColor(isSelected: id == selected)))
                .frame(width: 24, height: 24)
        }
        .padding(.vertical, size == .large ? 11 : 8)
        .frame(minHeight: size == .large ? 72 : 40)
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
        }
    }
}
