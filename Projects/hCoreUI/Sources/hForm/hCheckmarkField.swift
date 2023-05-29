import SwiftUI
import Combine
public struct hCheckmarkField: View {
    private let text: String
    @Binding var selected: Bool
    @State private var animate = false

    public init(text: String, selected: Binding<Bool>) {
        self._selected = selected
        self.text = text
        self.animate = animate
    }
    
    public var body: some View {
        HStack {
            Text(text)
            Spacer()
            if selected {
                Image(uiImage: hCoreUIAssets.checkmark.image)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .modifier(hFontModifierNew(style: .body))
        .foregroundColor (hLabelColorNew.primary)
        .animation(.easeOut(duration: 0.1))
        .background(getColor())
        .animation(.easeInOut(duration: 0.4), value: animate)
        .clipShape(Squircle.default())
        .onTapGesture {
            self.selected.toggle()
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }

    }
    
    @hColorBuilder
    private func getColor() -> some hColor {
        if animate {
            hBackgroundColorNew.inputBackgroundActive
        } else {
            hBackgroundColorNew.inputBackground
        }
    }
}
