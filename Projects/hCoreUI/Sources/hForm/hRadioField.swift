import Combine
import SwiftUI
import hCore

public struct hRadioField<Content: View>: View {
    private let content: Content
    private let id: String
    @Binding var selected: String?
    @Binding private var error: String?
    @State private var animate = false

    public init(
        id: String,
        content: @escaping () -> Content,
        selected: Binding<String?>,
        error: Binding<String?>? = nil
    ) {
        self.id = id
        self.content = content()
        self._selected = selected
        self._error = error ?? Binding.constant(nil)
    }

    public var body: some View {
        HStack {
            content
            Spacer()
            Circle()
                .strokeBorder(
                    getBorderColor(isSelected: id == selected),
                    lineWidth: id == selected ? 0 : 1.5
                )
                .background(Circle().foregroundColor(retColor(isSelected: id == selected)))
                .frame(width: 24, height: 24)
        }
        .padding(.vertical, 11)
        .frame(minHeight: 72)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            ImpactGenerator.soft()
            withAnimation(.none) {
                self.selected = id
            }
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hFillColorNew.opaqueOne
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hBorderColorNew.opaqueTwo
        }
    }
}
