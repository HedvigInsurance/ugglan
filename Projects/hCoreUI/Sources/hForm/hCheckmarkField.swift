import SwiftUI
import Combine
public struct hCheckmarkField: View {
    private let text: String
    @Binding var selected: Bool
    @Binding private var error: String?
    @State private var animate = false

    public init(text: String, selected: Binding<Bool>, error: Binding<String?>? = nil) {
        self._selected = selected
        self.text = text
        self._error = error ?? Binding.constant(nil)
    }
    
    public var body: some View {
        HStack {
            hTextNew(text, style: .title3)
            Spacer()
            if selected {
                Image(uiImage: hCoreUIAssets.checkmark.image)
            }
        }
        .padding(.vertical, 20)
        .modifier(hFontModifierNew(style: .body))
        .foregroundColor (hLabelColorNew.primary)
        .addFieldBackground(animate: $animate, error: $error)
        .onTapGesture {
            self.selected.toggle()
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
    }
}
