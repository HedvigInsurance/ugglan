import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingTextField<Value: hTextFieldFocusStateCompliant>: View {
    @Environment(\.hTextFieldOptions) var options
    private var masking: Masking
    private var placeholder: String
    private var suffix: String?
    @State private var innerValue: String = ""
    @State private var animate = false
    @State private var previousInnerValue: String = ""
    @State private var shouldMoveLabel: Bool = false
    @State private var textField: UITextField?
    @State private var observer = TextFieldObserver()
    @Binding var error: String?
    @Binding var value: String
    @Binding var equals: Value?
    let focusValue: Value
    let onReturn: () -> Void
    let openKeyboardOnStart: Bool?

    public init(
        masking: Masking,
        value: Binding<String>,
        equals: Binding<Value?>,
        focusValue: Value,
        placeholder: String? = nil,
        suffix: String? = nil,
        error: Binding<String?>? = nil,
        onReturn: @escaping () -> Void = {},
        openKeyboardOnStart: Bool = false
    ) {
        self.masking = masking
        self.placeholder = placeholder ?? masking.placeholderText ?? ""
        self.suffix = suffix
        self._value = value

        self._equals = equals
        self.focusValue = focusValue
        self.onReturn = onReturn
        self.openKeyboardOnStart = openKeyboardOnStart
        self._error = error ?? Binding.constant(nil)
        self._previousInnerValue = State(initialValue: value.wrappedValue)
        self._innerValue = State(initialValue: value.wrappedValue)
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                hFieldLabel(
                    placeholder: placeholder,
                    animate: $animate,
                    error: $error,
                    shouldMoveLabel: $shouldMoveLabel
                )

                getTextField
            }
            .padding(.vertical, shouldMoveLabel ? 10 : 0)
        }
        .introspectTextField { textField in
            if openKeyboardOnStart ?? false {
                self.textField?.becomeFirstResponder()
                shouldMoveLabel = true
            }

            if self.textField != textField {
                self.textField = textField
            }
        }
        .onChange(of: textField) { textField in
            textField?.delegate = observer
            if focusValue == Value.last {
                textField?.returnKeyType = .done
            }
            observer.onBeginEditing = {
                withAnimation {
                    self.error = nil
                }
                updateMoveLabel()
                startAnimation(self.innerValue)
                equals = focusValue
            }
            observer.onDidEndEditing = {
                updateMoveLabel()
            }
            observer.onReturnTap = {
                if let next = equals?.next {
                    equals = next
                } else {
                    equals = nil
                    textField?.resignFirstResponder()
                }
                updateMoveLabel()
                onReturn()
            }
        }
        .onChange(of: equals) { equals in
            if equals == focusValue {
                self.textField?.becomeFirstResponder()
            }
        }
        .onChange(of: innerValue) { currentValue in
            startAnimation(currentValue)
        }
        .onAppear {
            updateMoveLabel()
        }
        .addFieldBackground(animate: $animate, error: $error)
        .onTapGesture {
            textField?.becomeFirstResponder()
        }
    }

    private func startAnimation(_ value: String) {
        self.animate = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if value == innerValue {
                self.animate = false
            }
        }
    }

    private func updateMoveLabel() {
        if ((textField?.isEditing ?? false) || innerValue != "") && !shouldMoveLabel {
            withAnimation(Animation.easeInOut(duration: 0.2)) {
                shouldMoveLabel = true
            }
        } else if shouldMoveLabel && innerValue == "" {
            withAnimation(Animation.easeInOut(duration: 0.2)) {
                shouldMoveLabel = false
            }
        }
    }

    private var getTextField: some View {
        let fieldPointSize = HFontTextStyleNew.title3.uifontTextStyleNew.pointSize * 1.25
        return SwiftUI.TextField("", text: $innerValue)
            .modifier(hFontModifierNew(style: .title3))
            .modifier(masking)
            .tint(hLabelColorNew.primary)
            .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
                // when clicking
                if shouldUpdate {
                    value = masking.maskValue(text: innerValue, previousText: previousInnerValue)
                    if suffix != nil && value != "" {
                        innerValue = value + " " + (suffix ?? "")
                        let endPosition = textField?.position(from: textField!.beginningOfDocument, offset: value.count)
                        if let endPosition = endPosition {
                            textField?.selectedTextRange = textField?.textRange(from: endPosition, to: endPosition)
                        }
                    } else {
                        innerValue = value
                    }
                    previousInnerValue = value
                }
            }
            .frame(height: shouldMoveLabel ? fieldPointSize : 0)
            .padding(.vertical, shouldMoveLabel ? 2 : 0)
    }
}

struct hFloatingTextField_Previews: PreviewProvider {
    @State static var value: String = ""
    static var previews: some View {

        VStack {
            hFloatingTextField<Bool>(
                masking: .init(type: .none),
                value: $value,
                equals: Binding(
                    get: {
                        return nil
                    },

                    set: { _ in

                    }
                ),
                focusValue: true,
                placeholder: "Placeholder"
            )
        }
    }
}
