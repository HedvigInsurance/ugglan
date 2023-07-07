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
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    hFieldLabel(
                        placeholder: placeholder,
                        animate: $animate,
                        error: $error,
                        shouldMoveLabel: shouldMoveLabel
                    )
                    if !textToShow.isEmpty {
                        getTextLabel
                    }
                }
                .padding(.vertical, textToShow.isEmpty ? 0 : 10 - HFontTextStyleNew.title3.uifontLineHeightDifference)

                .frame(maxWidth: .infinity, alignment: .leading)
            }

            SwiftUI.Button {
                if let minValue, minValue < value {
                    decrease()
                } else {
                    decrease()
                }
            } label: {
                Image(uiImage: hCoreUIAssets.minusIcon.image)
                    .foregroundColor(
                        hTextColorNew.primary.opacity(value == 0 ? 0.4 : 1)

                    )
                    .frame(width: 35, height: 35)
            }

            SwiftUI.Button {
                if let maxValue, maxValue > value {
                    increase()
                } else {
                    increase()
                }
            } label: {
                Image(uiImage: hCoreUIAssets.plusIcon.image)
                    .foregroundColor(hTextColorNew.primary)
                    .frame(width: 35, height: 35)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .onTapGesture {
            self.startAnimation()
        }
        .onAppear {
            self.textToShow = textForValue(value) ?? ""
        }
    }

    private func increase() {
        withAnimation {
            value += 1
            startAnimation()
            self.textToShow = textForValue(value) ?? ""
        }
    }

    private func decrease() {
        withAnimation {
            value -= 1
            startAnimation()
            self.textToShow = textForValue(value) ?? ""
        }
    }

    private var getTextLabel: some View {
        hTextNew(textToShow, style: .title3)
            .foregroundColor(hTextColorNew.primary)
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
    @State static var value: Int = 0
    static var previews: some View {
        hCounterField(value: $value, placeholder: "Placeholder", minValue: 0, maxValue: 5) { value in
            if value == 0 {
                return nil
            } else {
                return "VALUE \(value)"
            }
        }
    }
}
