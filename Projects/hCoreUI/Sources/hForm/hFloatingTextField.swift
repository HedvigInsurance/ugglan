import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingTextField<Value: hTextFieldFocusStateCompliant>: View {
    @Environment(\.hTextFieldOptions) var options
    @Environment(\.hTextFieldError) var errorMessage

    private var masking: Masking
    private var placeholder: String
    private var suffix: String?
    @State private var innerValue: String = ""
    @State private var animate = false
    @State private var previousInnerValue: String = ""
    @State private var shouldMoveLabel: Bool = false
    @State private var textField: UITextField?
    @State private var observer = TextFieldObserver()
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
        onReturn: @escaping () -> Void = {}
    ) {
        self.masking = masking
        self.placeholder = placeholder ?? masking.placeholderText ?? ""
        self.suffix = suffix
        self._value = value

        self._equals = equals
        self.focusValue = focusValue
        self.onReturn = onReturn

        self.previousInnerValue = value.wrappedValue
        self.innerValue = value.wrappedValue
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                getFieldLabel
                getTextField
            }
            .padding(.horizontal, 16)
            .padding(.vertical, shouldMoveLabel ? 10 : 16)
            .background(getColor())
            .clipShape(Squircle.default())
        }
        .introspectTextField { textField in
            if self.textField != textField {
                self.textField = textField
            }
        }
        .onTapGesture {
            textField?.becomeFirstResponder()
        }
        .onChange(of: textField) { textField in
            textField?.delegate = observer
            if focusValue == Value.last {
                textField?.returnKeyType = .done
            }
            observer.onBeginEditing = {
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
    
    @hColorBuilder
    private func getColor() -> some hColor {
        if animate {
            hBackgroundColorNew.inputBackgroundActive
        } else {
            hBackgroundColorNew.inputBackground
        }
    }

    private var getFieldLabel: some View {
        let sizeToScaleFrom = HFontTextStyleNew.title3.uifontTextStyleNew.pointSize
        let sizeToScaleTo = HFontTextStyleNew.footnote.uifontTextStyleNew.pointSize
        let ratio = sizeToScaleTo / sizeToScaleFrom
        let difference = sizeToScaleTo - sizeToScaleFrom
        return Text(placeholder)
            .modifier(hFontModifierNew(style: .title3))
            .scaleEffect(shouldMoveLabel ? ratio : 1, anchor: .leading)
            .foregroundColor(hLabelColorNew.secondary)
            .padding(.vertical, shouldMoveLabel ? difference / 2 : 0)
    }

    private var getTextField: some View {
        let fieldPointSize = HFontTextStyleNew.title3.uifontTextStyleNew.pointSize
        return SwiftUI.TextField("", text: $innerValue)
            .modifier(hFontModifierNew(style: .title3))
            .modifier(masking)
            .tint(hLabelColorNew.primary)
            .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
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
            }.frame(maxHeight: shouldMoveLabel ? fieldPointSize * 1.25 : 0)
    }
}
