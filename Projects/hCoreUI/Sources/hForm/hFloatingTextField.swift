import Combine
import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public struct hFloatingTextField<Value: hTextFieldFocusStateCompliant>: View {
    @Environment(\.hFieldSize) var size
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hFieldRightAttachedView) var rightAttachedView
    @StateObject private var vm = TextFieldVM()

    @State private var animationEnabled: Bool = true
    @State private var innerValue: String = ""
    @State private var animate = false
    @State private var previousInnerValue: String = ""
    @State private var shouldMoveLabel: Bool = false
    @Binding var error: String?
    @Binding var value: String
    @Binding var equals: Value?

    private var masking: Masking
    private var placeholder: String
    private var suffix: String?
    private let focusValue: Value
    private let onReturn: () -> Void
    private let textFieldPlaceholder: String?

    public init(
        masking: Masking,
        value: Binding<String>,
        equals: Binding<Value?>,
        focusValue: Value,
        placeholder: String? = nil,
        suffix: String? = nil,
        error: Binding<String?>? = nil,
        textFieldPlaceholder: String? = nil,
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
        self.textFieldPlaceholder = textFieldPlaceholder
        updateMoveLabel(false)
    }

    public var body: some View {
        HStack(spacing: 8) {
            VStack {
                ZStack(alignment: .leading) {
                    hFieldLabel(
                        placeholder: placeholder,
                        animate: $animate,
                        error: $error,
                        shouldMoveLabel: $shouldMoveLabel
                    )
                    .offset(y: shouldMoveLabel ? size.labelOffset : 0)
                    HStack {
                        getTextField
                            .showClearButtonOrError(
                                $innerValue,
                                equals: $equals,
                                animationEnabled: $animationEnabled,
                                error: $error,
                                focusValue: focusValue
                            )
                        if !(suffix ?? "").isEmpty {
                            getSuffixLabel
                        }
                    }
                    .offset(y: shouldMoveLabel ? size.fieldOffset : 0)

                }
                .padding(.top, size.topPadding)
                .padding(.bottom, size.bottomPadding)
            }
            rightAttachedView
        }
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onChange(of: vm.textField) { [weak vm] textField in
            textField?.delegate = vm?.observer
            if focusValue == Value.last {
                textField?.returnKeyType = .done
            }

            func dismissKeyboard() {
                textField?.resignFirstResponder()
            }

            vm?.observer.onBeginEditing = {
                vm?.onBeginEditing = Date()
            }
            vm?.observer.onDidEndEditing = {
                vm?.onDidEndEditing = Date()
            }
            vm?.observer.onReturnTap = {
                vm?.onReturnTap = Date()
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
            withAnimation {
                self.error = nil
            }
            if animationEnabled {
                updateMoveLabel(true)
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
        .introspect(.textField, on: .iOS(.v13...)) { [weak vm] textField in
            vm?.textField = textField
            if masking.keyboardType == .numberPad {
                let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
                let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                if (equals?.next) != nil {
                    let button = UIButton(type: .custom)
                    button.setTitle(L10n.generalDoneButton, for: .normal)
                    button.backgroundColor = .clear

                    let color = UIColor.BrandColorNew.primaryText().color
                    button.setTitleColor(color, for: .normal)
                    let nextButton = UIBarButtonItem(customView: button)
                    button.addTarget(vm, action: #selector(vm?.goToTheNextField(_:)), for: .touchUpInside)
                    toolbar.setItems([space, nextButton], animated: false)
                } else {
                    let doneButton = UIBarButtonItem(
                        barButtonSystemItem: .done,
                        target: self,
                        action: #selector(textField.dismissKeyboad)
                    )
                    toolbar.setItems([space, doneButton], animated: false)
                }
                vm?.textField?.inputAccessoryView = toolbar
            }
        }
        .onAppear {
            updateMoveLabel(false)
        }
        .onChange(of: vm.goToNext) { _ in
            equals = equals?.next
        }
        .onChange(of: vm.onBeginEditing) { _ in
            withAnimation {
                self.error = nil
            }
            updateMoveLabel(true)
            equals = focusValue
        }
        .onChange(of: vm.onDidEndEditing) { _ in
            updateMoveLabel(true)
        }
        .onChange(of: vm.onReturnTap) { [weak vm] _ in
            if let next = equals?.next {
                equals = next
            } else {
                equals = nil
                vm?.textField?.resignFirstResponder()
            }
            updateMoveLabel(true)
            onReturn()
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

    private func updateMoveLabel(_ animation: Bool) {
        if (innerValue != "" || equals == focusValue) && !shouldMoveLabel {
            if animation {
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    shouldMoveLabel = true
                }
            } else {
                shouldMoveLabel = true
            }
        } else if shouldMoveLabel && (innerValue == "" && equals != focusValue) {
            if animation {
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    shouldMoveLabel = false
                }
            } else {
                shouldMoveLabel = false
            }
        }
    }

    private var getTextField: some View {
        SwiftUI.TextField(shouldMoveLabel ? textFieldPlaceholder ?? "" : "", text: $innerValue)
            .modifier(hFontModifier(style: size == .large ? .body2 : .body1))
            .modifier(masking)
            .tint(foregroundColor)
            .foregroundColor(foregroundColor)
            .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
                if shouldUpdate {
                    let value = masking.maskValue(text: innerValue, previousText: previousInnerValue)
                    withAnimation {
                        self.value = value
                        innerValue = value
                        previousInnerValue = value
                    }
                }
            }

    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Translucent.secondary
        }
    }

    private var getSuffixLabel: some View {
        hText(suffix ?? "", style: .body2)
            .foregroundColor(hTextColor.Opaque.secondary)
    }
}

class TextFieldVM: ObservableObject {
    weak var textField: UITextField?
    var observer = TextFieldObserver()
    @Published var goToNext: Date?
    @Published var onBeginEditing: Date?
    @Published var onDidEndEditing: Date?
    @Published var onReturnTap: Date?

    @objc func goToTheNextField(_ sender: UIButton) {
        goToNext = Date()
    }
}

struct hFloatingTextField_Previews: PreviewProvider {
    @State static var value: String = "Text Input"
    @State static var error: String?
    @State static var previewType: PreviewType?
    static var previews: some View {
        VStack {
            hFloatingTextField<PreviewType>(
                masking: .init(type: .none),
                value: $value,
                equals: $previewType,
                focusValue: .first,
                placeholder: "Label",
                suffix: "SEK",
                error: $error
            )
            hFloatingTextField<PreviewType>(
                masking: .init(type: .none),
                value: $value,
                equals: $previewType,
                focusValue: .second,
                placeholder: "Label",
                error: $error
            )
            .disabled(true)
        }
        .hFieldSize(.large)

    }

    enum PreviewType: Int, CaseIterable, hTextFieldFocusStateCompliant {
        static var last: PreviewType {
            return PreviewType.allCases.last!
        }

        var next: PreviewType? {
            let rawValue = self.rawValue
            if let next = PreviewType(rawValue: rawValue + 1) {
                return next
            }
            return nil
        }

        case first
        case second
    }
}

public enum BackgroundOption {
    case translucent
    case negative
    case withoutDisabled
    case locked
    case secondary
}

private struct EnvironmentHBackgroundOption: EnvironmentKey {
    static let defaultValue: [BackgroundOption] = []
}

extension EnvironmentValues {
    public var hBackgroundOption: [BackgroundOption] {
        get { self[EnvironmentHBackgroundOption.self] }
        set { self[EnvironmentHBackgroundOption.self] = newValue }
    }
}

extension View {
    public func hBackgroundOption(option: [BackgroundOption]) -> some View {
        self.environment(\.hBackgroundOption, option)
    }
}

private struct EnvironmentHFieldSize: EnvironmentKey {
    static let defaultValue: hFieldSize = .large
}

public enum hFieldSize: Hashable {
    case small
    case large
    case medium
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return .padding14
        case .large:
            return .padding16
        case .medium:
            return .padding16
        }
    }
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

struct TextFieldClearButtonOrError<Value: hTextFieldFocusStateCompliant>: ViewModifier {
    @Binding var fieldText: String
    @Binding var equals: Value?
    @Binding var animationEnabled: Bool
    @Binding var error: String?
    let focusValue: Value
    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 0) {
            content
            if fieldText != "" && equals == focusValue {
                SwiftUI.Button(
                    action: {
                        fieldText = ""
                    },
                    label: {
                        Image(uiImage: hCoreUIAssets.close.image)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hTextColor.Opaque.primary)
                    }
                )

            } else if error != nil {
                Image(uiImage: HCoreUIAsset.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.Amber.element)
            }
        }
    }
}

extension View {
    func showClearButtonOrError<Value: hTextFieldFocusStateCompliant>(
        _ text: Binding<String>,
        equals: Binding<Value?>,
        animationEnabled: Binding<Bool>,
        error: Binding<String?>,
        focusValue: Value
    ) -> some View {
        self.modifier(
            TextFieldClearButtonOrError(
                fieldText: text,
                equals: equals,
                animationEnabled: animationEnabled,
                error: error,
                focusValue: focusValue
            )
        )
    }
}

extension hFieldSize {
    var labelOffset: CGFloat {
        switch self {
        case .small: return -13
        case .medium: return -14
        case .large: return -15
        }
    }

    var fieldOffset: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 8
        case .large: return 8
        }
    }

    var labelFont: HFontTextStyle {
        switch self {
        case .small: return .body1
        case .medium: return .body1
        case .large: return .body2
        }
    }
}

private struct EnvironmentHAnimateField: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    public var hAnimateField: Bool {
        get { self[EnvironmentHAnimateField.self] }
        set { self[EnvironmentHAnimateField.self] = newValue }
    }
}

extension View {
    public func hAnimateField(_ animate: Bool) -> some View {
        self.environment(\.hAnimateField, animate)
    }
}
