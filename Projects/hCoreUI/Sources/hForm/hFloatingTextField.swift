import Combine
import Flow
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingTextField<Value: hTextFieldFocusStateCompliant>: View {
    @Environment(\.hTextFieldOptions) var options
    @Environment(\.hFieldSize) var size
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hFieldRightAttachedView) var rightAttachedView
    @Namespace private var animationNamespace
    @State private var animationEnabled: Bool = true
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
        HStack(spacing: 8) {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        hFieldLabel(
                            placeholder: placeholder,
                            animate: $animate,
                            error: $error,
                            shouldMoveLabel: $shouldMoveLabel
                        )
                        Spacer()
                        if !(suffix ?? "").isEmpty && !shouldMoveLabel {
                            getSuffixLabel
                        }
                    }
                    getTextField
                }
                .padding(.vertical, shouldMoveLabel ? (size == .large ? 10 : 7.5) : 3)
            }
            .addFieldBackground(animate: $animate, error: $error)
            rightAttachedView
        }
        .addFieldError(animate: $animate, error: $error)
        .onChange(of: vm.textField) { textField in
            textField?.delegate = observer
            if focusValue == Value.last {
                textField?.returnKeyType = .done
            }

            func dismissKeyboard() {
                textField?.resignFirstResponder()
            }
            observer.onBeginEditing = {
                withAnimation {
                    self.error = nil
                }
                updateMoveLabel(true)
                equals = focusValue

                if masking.keyboardType == .numberPad {
                    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
                    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    if let next = equals?.next {
                        let button = UIButton(type: .custom)
                        button.setTitle(L10n.generalNextButton)
                        button.backgroundColor = .clear

                        let color = UIColor.BrandColorNew.primaryText().color
                        button.setTitleColor(color, for: .normal)
                        let nextButton = UIBarButtonItem(button: button)

                        vm.disposeBag += button.signal(for: .touchUpInside)
                            .onValue { _ in
                                equals = equals?.next
                            }
                        toolbar.setItems([space, nextButton], animated: false)
                    } else {
                        let doneButton = UIBarButtonItem(
                            barButtonSystemItem: .done,
                            target: self,
                            action: #selector(textField?.dismissKeyboad)
                        )
                        toolbar.setItems([space, doneButton], animated: false)
                    }
                    textField?.inputAccessoryView = toolbar
                }
            }
            observer.onDidEndEditing = {
                updateMoveLabel(true)
            }
            observer.onReturnTap = { [weak textField] in
                if let next = equals?.next {
                    equals = next
                } else {
                    equals = nil
                    textField?.resignFirstResponder()
                }
                updateMoveLabel(true)
                onReturn()
            }
            if equals == focusValue {
                textField?.becomeFirstResponder()
            }
        }
        .onChange(of: equals) { equals in
            if equals == focusValue {
                self.vm.textField?.becomeFirstResponder()
            } else if self.vm.textField?.isEditing == true {
                self.vm.textField?.resignFirstResponder()
            }
        }
        .onChange(of: innerValue) { currentValue in
            self.error = nil
            if animationEnabled {
                startAnimation(currentValue)
            }
        }
        .onTapGesture {
            self.equals = self.focusValue
            self.vm.textField?.becomeFirstResponder()
        }
        .onChange(of: error) { error in
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
        .introspectTextField { textField in
            weak var `textField` = textField
            if self.vm.textField != textField {
                self.vm.textField = textField
            }
        }
        .onAppear {
            updateMoveLabel(false)
        }
        .onDisappear {
            vm.textField = nil
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

    private func dismiss() {

    }

    private func updateMoveLabel(_ animation: Bool) {
        if ((vm.textField?.isEditing ?? false) || innerValue != "") && !shouldMoveLabel {
            if animation {
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    shouldMoveLabel = true
                }
            } else {
                shouldMoveLabel = true
            }
        } else if shouldMoveLabel && innerValue == "" {
            if animation {

                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    shouldMoveLabel = false
                }
            } else {
                shouldMoveLabel = true
            }
        }
    }

    private var getTextField: some View {
        return HStack {
            SwiftUI.TextField("", text: $innerValue)
                .modifier(hFontModifier(style: size == .large ? .title3 : .standard))
                .modifier(masking)
                .tint(foregroundColor)
                .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
                    if shouldUpdate {
                        let value = masking.maskValue(text: innerValue, previousText: previousInnerValue)
                        self.value = value
                        innerValue = value
                        previousInnerValue = value
                    }
                }
                .frame(
                    height: getHeight()
                )
                .showClearButton(
                    $innerValue,
                    equals: $equals,
                    animationEnabled: $animationEnabled,
                    focusValue: focusValue
                )
            if !(suffix ?? "").isEmpty && shouldMoveLabel {
                getSuffixLabel
            }
        }
    }

    private func getHeight() -> CGFloat {
        let value =
            (shouldMoveLabel)
            ? (size == .large ? HFontTextStyle.title3.fontSize : HFontTextStyle.standard.fontSize) + 6 : 0
        return value
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
            .foregroundColor(hTextColorNew.tertiary).matchedGeometryEffect(id: "sufixLabel", in: animationNamespace)
    }
}

class TextFieldVM: ObservableObject {
    @Published var textField: UITextField?
    let disposeBag = DisposeBag()

}

struct hFloatingTextField_Previews: PreviewProvider {
    @State static var value: String = "Ss"
    @State static var error: String?
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
            //            .hFieldSize(.small)
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
                suffix: "m2",
                error: $error
            )
        }
    }
}

private struct EnvironmentHFieldSize: EnvironmentKey {
    static let defaultValue: hFieldSize = .large
}

extension EnvironmentValues {
    public var hFieldSize: hFieldSize {
        get { self[EnvironmentHFieldSize.self] }
        set { self[EnvironmentHFieldSize.self] = newValue }
    }
}

extension View {
    public func hFieldSize(_ size: hFieldSize) -> some View {
        self.environment(\.hFieldSize, size)
    }
}

public enum hFieldSize: Hashable {
    case small
    case large
}

private struct EnvironmentHFieldAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hFieldRightAttachedView: AnyView? {
        get { self[EnvironmentHFieldAttachedView.self] }
        set { self[EnvironmentHFieldAttachedView.self] = newValue }
    }
}

extension View {
    public func hFieldAttachToRight<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hFieldRightAttachedView, AnyView(content()))
    }
}

struct TextFieldClearButton<Value: hTextFieldFocusStateCompliant>: ViewModifier {
    @Binding var fieldText: String
    @Binding var equals: Value?
    @Binding var animationEnabled: Bool
    let focusValue: Value
    func body(content: Content) -> some View {
        HStack(alignment: .center) {
            content
            if fieldText != "" && equals == focusValue {
                Color.clear
                    .fixedSize()
                    .background(
                        SwiftUI.Button(
                            action: {
                                animationEnabled = false
                                fieldText = ""
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    animationEnabled = true
                                }
                            },
                            label: {
                                Image(uiImage: hCoreUIAssets.closeSmall.image)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(hTextColorNew.primary)
                            }
                        )
                    )

            }
        }
    }
}

extension View {
    func showClearButton<Value: hTextFieldFocusStateCompliant>(
        _ text: Binding<String>,
        equals: Binding<Value?>,
        animationEnabled: Binding<Bool>,
        focusValue: Value
    ) -> some View {
        self.modifier(
            TextFieldClearButton(
                fieldText: text,
                equals: equals,
                animationEnabled: animationEnabled,
                focusValue: focusValue
            )
        )
    }
}
