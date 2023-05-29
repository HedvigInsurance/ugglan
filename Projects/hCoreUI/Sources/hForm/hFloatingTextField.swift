import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingTextField<Value: hTextFieldFocusStateCompliant>: View {
    @Environment(\.hTextFieldOptions) var options
    @Environment(\.hTextFieldError) var errorMessage
    @Environment(\.hUseNewStyle) var hUseNewStyle

    private var masking: Masking
    private var placeholder: String
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
    @StateObject var model = hFloatingTextFieldModel()

    public init(
        masking: Masking,
        value: Binding<String>,
        equals: Binding<Value?>,
        focusValue: Value,
        onReturn: @escaping () -> Void = {}
    ) {
        self.masking = masking
        self.placeholder = masking.placeholderText ?? ""
        self._value = value

        self._equals = equals
        self.focusValue = focusValue
        self.onReturn = onReturn

        self.previousInnerValue = value.wrappedValue
        self.innerValue = value.wrappedValue

    }

    public var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                getFieldLabel()
                getTextField()
            }
            .padding(.horizontal, 16)
            .background(getColor())
            .animation(.easeInOut(duration: 0.4), value: animate)
            .clipShape(Squircle.default())
            if let errorMessage = errorMessage {
                HStack {
                    Image(uiImage: hCoreUIAssets.circularExclamationPoint.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(hTintColor.red)
                    hText(errorMessage, style: .footnote)
                        .padding(.top, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(hTintColor.red)
                }
            }
        }
        .introspectTextField { textField in
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
                updateMoveLabel()
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
                }
                updateMoveLabel()
                textField?.resignFirstResponder()
                onReturn()
            }

        }
        .onChange(of: equals) { equals in
            if equals == focusValue {
                self.textField?.becomeFirstResponder()
            }
        }
        .onChange(of: innerValue) { currentValue in
            startAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if currentValue == innerValue {
                    self.animate = false
                }
            }
        }
    }

    private func updateMoveLabel() {
        if ((textField?.isEditing ?? false) || innerValue != "") && !shouldMoveLabel {
            shouldMoveLabel = true
        } else if shouldMoveLabel && innerValue == "" {
            shouldMoveLabel = false
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

    private func getFieldLabel() -> some View {
        Text("PlaceHolderText")
            .modifier(hFontModifierNew(style: .body))
            .foregroundColor(hLabelColorNew.secondary)
            .padding(
                shouldMoveLabel
                    ? EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
                    : EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
            )
            .scaleEffect(shouldMoveLabel ? 0.8 : 1, anchor: .leading)
            .animation(.easeOut(duration: 0.1))
    }

    private func getTextField() -> some View {
        SwiftUI.TextField("", text: $innerValue)
            .modifier(hFontModifierNew(style: .body))
            .modifier(masking)
            .tint(hLabelColorNew.primary)
            .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
                if shouldUpdate {
                    value = masking.maskValue(text: innerValue, previousText: previousInnerValue)
                    innerValue = value
                    previousInnerValue = value
                }
            }
            .frame(minHeight: options.minimumHeight)
            .padding(EdgeInsets(top: 26.67, leading: 0, bottom: 13.33, trailing: 0))
    }

    private func startAnimation() {
        self.animate = true
    }

    class hFloatingTextFieldModel: ObservableObject {
        var cancellables = Set<AnyCancellable>()
    }
}
