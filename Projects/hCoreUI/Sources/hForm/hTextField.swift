import Combine
import Foundation
import SwiftUI
import hCore

public struct hTextField: View {
    var masking: Masking
    var placeholder: String
    @State var previousValue: String
    @State var value: String
    @Binding var unmaskedValue: String

    public init(
        placeholder: String,
        value: String
    ) {
        self.placeholder = placeholder
        self.value = value
        self.previousValue = value
        self._unmaskedValue = Binding(get: { value }, set: { _ in })
        self.masking = Masking(type: .none)
    }

    public init(
        masking: Masking,
        value: String
    ) {
        self.masking = masking
        self.placeholder = masking.placeholderText ?? ""
        self.value = value
        self.previousValue = value
        self._unmaskedValue = Binding(get: { value }, set: { _ in })
    }

    public init(
        masking: Masking,
        value: Binding<String>
    ) {
        self.masking = masking
        self.placeholder = masking.placeholderText ?? ""
        self.value = value.wrappedValue
        self.previousValue = value.wrappedValue
        self._unmaskedValue = value
    }

    public var body: some View {
        VStack {
            SwiftUI.TextField(placeholder, text: $value)
                .modifier(hFontModifier(style: .body))
                .modifier(masking)
                .tint(hLabelColor.primary)
                .onReceive(Just(value)) { value in
                    self.value = masking.maskValue(text: value, previousText: previousValue)
                    self.unmaskedValue = self.masking.unmaskedValue(text: self.value)
                    previousValue = value
                }
                .frame(minHeight: 40)
            SwiftUI.Divider()
        }
    }
}

struct hTextFieldPreview: PreviewProvider {
    static var previews: some View {
        hTextField(placeholder: "Placeholder", value: "Test")
            .padding(20)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Active with value")
        hTextField(placeholder: "Placeholder", value: "")
            .padding(20)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Placeholder")
        hTextField(placeholder: "Placeholder", value: "Test")
            .padding(20)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark mode")
        hTextField(masking: Masking(type: .personalNumber), value: "")
            .padding(20)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Masked with Swedish Personal Number")
    }
}
