import SwiftUI
import hCore

public struct hRadioOptionField: View {
    private var placeholder: String
    @Binding private var value: String?
    @State private var animate = false
    private var useAnimation: Bool
    @Binding var error: String?
    private var listOfOptions: [String]

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { true },
            set: { _ in }
        )
    }

    public init(
        value: Binding<String?>?,
        placeholder: String? = nil,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false,
        listOfOptions: [String]? = [L10n.General.yes, L10n.General.no]
    ) {
        self.placeholder = placeholder ?? ""
        self._value = value ?? Binding.constant(nil)
        self._error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
        self.listOfOptions = listOfOptions ?? []
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hFieldLabel(
                placeholder: placeholder,
                animate: $animate,
                error: $error,
                shouldMoveLabel: shouldMoveLabel
            )
            .padding(.bottom, 13)

            HStack(spacing: 16) {
                getCheckBox(texts: listOfOptions)
                Spacer()
            }
        }
        .padding(.vertical, 16)
        .addFieldBackground(animate: $animate, error: $error)
    }

    func getCheckBox(texts: [String]) -> some View {
        ForEach(texts, id: \.self) { text in
            HStack(spacing: 8) {
                Circle()
                    .strokeBorder(
                        RadioFieldsColors().getBorderColor(isSelected: text == value),
                        lineWidth: text == value ? 0 : 1.5
                    )
                    .background(
                        Circle().foregroundColor(RadioFieldsColors().getFillColor(isSelected: text == value))
                    )
                    .frame(width: 24, height: 24)

                Text(text)
            }
            .onTapGesture {
                ImpactGenerator.soft()
                withAnimation(.none) {
                    self.value = text
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
}

struct hRadioOptionField_Previews: PreviewProvider {
    static var previews: some View {
        @State var value: String? = "test"
        hForm {
            VStack {
                hRadioOptionField(value: $value, placeholder: "Was your bike locked?", useAnimation: true)
            }
        }
    }
}
