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
    @Environment(\.hFieldSize) var size

    @State var shouldMoveLabel: Bool = false
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
                HStack {
                    ZStack(alignment: .leading) {
                        HStack {
                            hFieldLabel(
                                placeholder: placeholder,
                                animate: $animate,
                                error: $error,
                                shouldMoveLabel: $shouldMoveLabel
                            )
                        }
                        .offset(y: shouldMoveLabel ? size.labelOffset : 0)
                        getTextLabel
                            .offset(y: shouldMoveLabel ? size.fieldOffset : 0)
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
                        Image(uiImage: hCoreUIAssets.plus.image)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .frame(width: 35, height: 35)
                    }
                }
                .padding(.top, size.counterTopPadding)
                .padding(.bottom, size.counterBottomPadding)
            }
        }
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            self.startAnimation()
        }
        .onAppear {
            self.textToShow = textForValue(value) ?? ""
        }
        .onChange(of: textToShow) { value in
            shouldMoveLabel = placeholder != "" && value != ""
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
        hText(textToShow, style: size == .large ? .body2 : .body1)
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
        let counerWithPlaceholder = hCounterField(value: $value, placeholder: "Placeholder", minValue: 0, maxValue: 5) {
            value in
            if value == 0 {
                return nil
            } else {
                return "VALUE \(value)"
            }
        }

        let counerWithWithoutPlaceholder = hCounterField(value: $value, placeholder: "", minValue: 0, maxValue: 5) {
            value in
            if value == 0 {
                return nil
            } else {
                return "VALUE \(value)"
            }
        }
        return VStack(alignment: .leading) {
            Section("With placeholder") {
                counerWithPlaceholder
                    .hFieldSize(.large)

                counerWithPlaceholder
                    .hFieldSize(.medium)

                counerWithPlaceholder
                    .hFieldSize(.small)
            }
            Section("Without placeholder") {
                counerWithWithoutPlaceholder
                    .hFieldSize(.large)

                counerWithWithoutPlaceholder
                    .hFieldSize(.medium)

                counerWithWithoutPlaceholder
                    .hFieldSize(.small)
            }
        }
    }
}

extension hFieldSize {
    var counterTopPadding: CGFloat {
        switch self {
        case .small:
            return 10
        case .large:
            return 15
        case .medium:
            return 15
        }
    }

    var counterBottomPadding: CGFloat {
        counterTopPadding - 1
    }
}
