import SwiftUI

public struct hCounterField: View {
    private var placeholder: String
    @State private var animate = false
    @Binding var value: Int
    @Binding var error: String?
    let minValue: Int?
    let maxValue: Int?
    @State var textToShow: String = ""
    private let textForValue: (_ value: Int) -> String?
    @Environment(\.isEnabled) var isEnabled

    var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { !textToShow.isEmpty },
            set: { _ in }
        )
    }
    public init(
        value: Binding<Int>,
        placeholder: String? = nil,
        minValue: Int? = nil,
        maxValue: Int? = nil,
        error: Binding<String?>? = nil,
        textForValue: @escaping (Int) -> String?
    ) {

        self.placeholder = placeholder ?? ""
        self.textForValue = textForValue
        self.minValue = minValue
        self.maxValue = maxValue
        self._value = value
        self._error = error ?? Binding.constant(nil)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    hFieldLabel(
                        placeholder: placeholder,
                        animate: $animate,
                        error: $error,
                        shouldMoveLabel: shouldMoveLabel
                    )
                    HStack(spacing: 0) {
                        if !textToShow.isEmpty {
                            getTextLabel
                        }
                        Spacer()
                        SwiftUI.Button {
                            if let minValue, minValue < value {
                                decrease()
                            }
                        } label: {
                            Image(uiImage: hCoreUIAssets.minus.image)
                                .foregroundColor(
                                    hTextColor.Opaque.primary.opacity(value == 0 ? 0.4 : 1)

                                )
                                .frame(width: 35, height: 35)
                        }
                        SwiftUI.Button {
                            if let maxValue, maxValue > value {
                                increase()
                            }
                        } label: {
                            Image(uiImage: hCoreUIAssets.plusSmall.image)
                                .foregroundColor(hTextColor.Opaque.primary)
                                .frame(width: 35, height: 35)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            self.startAnimation()
        }
        .onAppear {
            self.textToShow = textForValue(value) ?? ""
        }
    }

    private func increase() {
        value += 1
        startAnimation()
        self.textToShow = textForValue(value) ?? ""
    }

    private func decrease() {
        value -= 1
        startAnimation()
        self.textToShow = textForValue(value) ?? ""
    }

    private var getTextLabel: some View {
        hText(textToShow, style: .title3)
            .foregroundColor(hTextColor.Opaque.primary)
    }

    private func startAnimation() {
        withAnimation {
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    self.animate = false
                }
            }
        }
    }
}

struct hCounterField_Previews: PreviewProvider {
    @State static var value: Int = 1
    static var previews: some View {
        VStack {
            hCounterField(value: $value, placeholder: "Placeholder", minValue: 0, maxValue: 5) { value in
                if value == 0 {
                    return nil
                } else {
                    return "VALUE \(value)"
                }
            }
        }
        .background(Color.blue)
    }
}
