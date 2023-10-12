import Combine
import SwiftUI

public struct hCheckmarkField: View {
    private let text: String
    @Binding var selected: Bool
    @Binding private var error: String?
    @State private var animate = false

    public init(
        text: String,
        selected: Binding<Bool>,
        error: Binding<String?>? = nil
    ) {
        self._selected = selected
        self.text = text
        self._error = error ?? Binding.constant(nil)
    }

    public var body: some View {
        HStack {
            hText(text, style: .title3)
            Spacer()
            if selected {
                Image(uiImage: hCoreUIAssets.tick.image).resizable().frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 20)
        .modifier(hFontModifier(style: .body))
        .foregroundColor(hTextColor.primary)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            self.selected.toggle()
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
    }
}
