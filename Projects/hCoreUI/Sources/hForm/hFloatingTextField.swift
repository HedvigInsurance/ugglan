import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingTextField<Value: hTextFieldFocusStateCompliant>: View {
    @Environment(\.hTextFieldOptions) var options
    @Environment(\.isEnabled) var isEnabled
    private var masking: Masking
    private var placeholder: String
    private var suffix: String?
    @State private var innerValue: String = ""
    @State private var animate = false
    @State private var previousInnerValue: String = ""
    @State private var shouldMoveLabel: Bool = false
    @State private var observer: TextFieldObserver = TextFieldObserver()
    @StateObject private var vm = TextFieldVM()

    @Binding var error: String?
    @Binding var value: String
    @Binding var equals: Value?
    let focusValue: Value
    let onReturn: () -> Void

    public init(
        masking: Masking,
        value: Binding<String>,
        equals: Binding<Value?>,
        focusValue: Value,
        placeholder: String? = nil,
        suffix: String? = nil,
        error: Binding<String?>? = nil,
        onReturn: @escaping () -> Void = {}
    ) {
        self.masking = masking
        self.placeholder = placeholder ?? masking.placeholderText ?? ""
        self.suffix = suffix
        self._value = value

        self._equals = equals
        self.focusValue = focusValue
        self.onReturn = onReturn
        self._error = error ?? Binding.constant(nil)
        self._previousInnerValue = State(initialValue: value.wrappedValue)
        self._innerValue = State(initialValue: value.wrappedValue)
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {

                if suffix != nil, suffix != "" {
                    HStack {
                        getTextField
                        Spacer()
                        getSuffixLabel
                    }
                    .padding(.vertical, 15)
                } else {
                    hFieldLabel(
                        placeholder: placeholder,
                        animate: $animate,
                        error: $error,
                        shouldMoveLabel: $shouldMoveLabel
                    )
                    getTextField
                }
            }
            .padding(.vertical, shouldMoveLabel ? 10 : 0)
        }
        .onChange(of: vm.textField) { textField in
            textField?.delegate = observer
            if focusValue == Value.last {
                textField?.returnKeyType = .done
            }

            observer.onBeginEditing = {
                withAnimation {
                    self.error = nil
                }
                updateMoveLabel()
                equals = focusValue
            }
            observer.onDidEndEditing = {
                updateMoveLabel()
            }
            observer.onReturnTap = { [weak textField] in
                if let next = equals?.next {
                    equals = next
                } else {
                    equals = nil
                    textField?.resignFirstResponder()
                }
                updateMoveLabel()
                onReturn()
            }
            if equals == focusValue {
                textField?.becomeFirstResponder()
            }
        }
        .onChange(of: equals) { equals in
            if equals == focusValue {
                self.vm.textField?.becomeFirstResponder()
            }
        }
        .onChange(of: innerValue) { currentValue in
            self.error = nil
            startAnimation(currentValue)
        }
        .onAppear {
            updateMoveLabel()
        }
        .addFieldBackground(animate: $animate, error: $error)
        .onTapGesture {
            vm.textField?.becomeFirstResponder()
        }
        .onChange(of: error) { error in
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
        .introspectTextField { textField in
            if self.vm.textField != textField {
                self.vm.textField = textField
            }
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
        if ((vm.textField?.isEditing ?? false) || innerValue != "") && !shouldMoveLabel {
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
        return SwiftUI.TextField("", text: $innerValue)
            .modifier(hFontModifier(style: .title3))
            .modifier(masking)
            .tint(foregroundColor)
            .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
                if shouldUpdate {
                    value = masking.maskValue(text: innerValue, previousText: previousInnerValue)
                    innerValue = value
                    previousInnerValue = value
                }
            }
            .frame(height: (shouldMoveLabel && suffix == nil) ? HFontTextStyle.title3.fontSize : 0)
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColorNew.primary
        } else {
            hTextColorNew.secondary
        }
    }

    private var getSuffixLabel: some View {
        hText(suffix ?? "", style: .title3)
            .foregroundColor(hTextColorNew.secondary)
    }
}

class TextFieldVM: ObservableObject {
    weak var textField: UITextField?
}

struct hFloatingTextField_Previews: PreviewProvider {
    @State static var value: String = "Test"
    @State static var error: String? = "Test"
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
                placeholder: "Label",
                error: $error
            )
        }
    }
}
