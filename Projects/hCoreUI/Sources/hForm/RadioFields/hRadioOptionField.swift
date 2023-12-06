import SwiftUI
import hCore

public struct hRadioOptionField: View {
    private var placeholder: String
    private var value: String
    @State private var animate = false
    private var useAnimation: Bool
    @Binding var error: String?

    @State var selected: String = ""

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { !value.isEmpty },
            set: { _ in }
        )
    }

    public init(
        value: String,
        placeholder: String? = nil,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false
    ) {
        self.placeholder = placeholder ?? ""
        self.value = value
        self._error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
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
                getCheckBox(texts: [L10n.General.yes, L10n.General.no])
                Spacer()
            }
        }
        .padding(.vertical, 16)
        .addFieldBackground(animate: $animate, error: $error)
        .padding(.horizontal, 16)
    }

    func getCheckBox(texts: [String]) -> some View {
        ForEach(texts, id: \.self) { text in
            HStack(spacing: 8) {
                Circle()
                    .strokeBorder(
                        RadioFieldsColors().getBorderColor(isSelected: text == selected),
                        lineWidth: text == selected ? 0 : 1.5
                    )
                    .background(
                        Circle().foregroundColor(RadioFieldsColors().getFillColor(isSelected: text == selected))
                    )
                    .frame(width: 24, height: 24)

                Text(text)
            }
            .onTapGesture {
                ImpactGenerator.soft()
                withAnimation(.none) {
                    self.selected = text
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
        hForm {
            VStack {
                hRadioOptionField(value: "test", placeholder: "Was your bike locked?", useAnimation: true)
            }
        }
    }
}
