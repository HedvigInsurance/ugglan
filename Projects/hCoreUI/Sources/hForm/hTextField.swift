import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public enum hTextFieldOptions: Hashable {
    case showDivider
    case minimumHeight(height: CGFloat)
}

extension Set where Element == hTextFieldOptions {
    var minimumHeight: CGFloat {
        self.compactMap { option in
            if case .minimumHeight(let height) = option {
                return height
            } else {
                return nil
            }
        }
        .first ?? 0.0
    }

    var showDivider: Bool {
        self.contains(.showDivider)
    }
}

private struct EnvironmentHTextFieldOptions: EnvironmentKey {
    static let defaultValue: Set<hTextFieldOptions> = [.showDivider, .minimumHeight(height: 40.0)]
}

extension EnvironmentValues {
    public var hTextFieldOptions: Set<hTextFieldOptions> {
        get { self[EnvironmentHTextFieldOptions.self] }
        set { self[EnvironmentHTextFieldOptions.self] = newValue }
    }
}

extension View {
    public func hTextFieldOptions(_ options: Set<hTextFieldOptions>) -> some View {
        self.environment(\.hTextFieldOptions, options)
    }
}

private struct EnvironmentHTextFieldError: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    public var hTextFieldError: String? {
        get { self[EnvironmentHTextFieldError.self] }
        set { self[EnvironmentHTextFieldError.self] = newValue }
    }
}

extension View {
    public func hTextFieldError(_ message: String?) -> some View {
        self.environment(\.hTextFieldError, message)
    }
}

public struct hTextField: View {
    @Environment(\.hTextFieldOptions) var options
    @Environment(\.hTextFieldError) var errorMessage

    var masking: Masking
    var placeholder: String?
    @State var previousInnerValue: String
    @State private var innerValue: String
    @Binding var value: String
    public init(
        masking: Masking,
        value: Binding<String>,
        placeholder: String? = nil
    ) {
        self.masking = masking
        self.placeholder = placeholder ?? masking.placeholderText
        self._value = value
        self.previousInnerValue = value.wrappedValue
        self.innerValue = value.wrappedValue
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                SwiftUI.TextField(placeholder ?? "", text: $innerValue)
                    .modifier(hFontModifier(style: .body))
                    .modifier(masking)
                    .tint(hLabelColor.primary)
                    .onReceive(Just(innerValue != previousInnerValue)) { shouldUpdate in
                        if shouldUpdate {
                            value = masking.maskValue(text: innerValue, previousText: previousInnerValue)
                            innerValue = value
                            previousInnerValue = value
                        }
                    }
                    .frame(minHeight: options.minimumHeight)
            }
            if options.showDivider {
                SwiftUI.Divider()
            }
            if let errorMessage = errorMessage {
                HStack {
                    hText(errorMessage, style: .footnote)
                        .padding(.top, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(hTintColor.red)
                }
            }
        }
    }
}

struct hTextFieldPreview: PreviewProvider {
    static var previews: some View {
        hTextField(masking: Masking(type: .personalNumber), value: .constant(""), placeholder: "")
            .padding(20)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Masked with Swedish Personal Number")
    }
}

@propertyWrapper public struct hTextFieldFocusState<Value: Hashable>: DynamicProperty {
    @State var field: Value?

    public var projectedValue: Binding<Value?> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    public var wrappedValue: Value? {
        get {
            return field
        }
        nonmutating set {
            field = newValue
        }
    }

    public init(
        wrappedValue: Value?
    ) {
        self._field = State(initialValue: wrappedValue)
    }
}

class TextFieldObserver: NSObject, UITextFieldDelegate {
    var onReturnTap: () -> Void = {}
    var onDidEndEditing: () -> Void = {}
    var onBeginEditing: () -> Void = {}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnTap()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onDidEndEditing()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        onBeginEditing()
    }

}

public protocol hTextFieldFocusStateCompliant: Hashable {
    static var last: Self { get }
    var next: Self? { get }
}

struct hTextFieldFocusStateModifier<Value: hTextFieldFocusStateCompliant>: ViewModifier {
    @State var isFirstAppear: Bool = true
    @State var navigationControllerHasFinishedTransition: Bool = false
    @State var textField: UITextField? = nil
    @State var observer = TextFieldObserver()

    @Binding var focusedField: Value?
    var equals: Value?
    var onReturn: () -> Void

    func setup() {
        textField?.delegate = observer

        observer.onReturnTap = {
            if let next = focusedField?.next {
                focusedField = next
            } else {
                focusedField = nil
            }

            onReturn()
        }

        observer.onDidEndEditing = {}

        if equals == Value.last {
            textField?.returnKeyType = .done
        } else {
            textField?.returnKeyType = .next
        }
    }

    func body(content: Content) -> some View {
        content.introspectTextField { textField in
            if self.textField != textField {
                self.textField = textField
            }
        }
        .onReceive(Just(focusedField.hashValue &+ navigationControllerHasFinishedTransition.hashValue)) { _ in
            guard navigationControllerHasFinishedTransition else {
                return
            }

            setup()

            if focusedField == equals {
                textField?.becomeFirstResponder()
            } else {
                textField?.resignFirstResponder()
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    focusedField = equals
                    setup()
                }
        )
        .onReceive(Just(textField != nil && !navigationControllerHasFinishedTransition)) { _ in
            guard let textField = textField else {
                return
            }

            if let navigationController = textField.viewController?.navigationController {
                if isFirstAppear && navigationController.viewControllers.count == 1 {
                    // skip waiting for transition if viewController is single viewController in UINavigationController
                    navigationControllerHasFinishedTransition = true
                } else {
                    navigationController.transitionCoordinator?
                        .animate(
                            alongsideTransition: nil,
                            completion: { _ in
                                navigationControllerHasFinishedTransition = true
                            }
                        )
                }
            } else {
                // no navigation controller so no need to wait for any transition
                navigationControllerHasFinishedTransition = true
            }
        }
        .onDisappear {
            isFirstAppear = false
            navigationControllerHasFinishedTransition = false
        }
    }
}

extension Bool: hTextFieldFocusStateCompliant {
    public static var last: Bool {
        true
    }

    public var next: Bool? {
        return nil
    }
}

extension hTextField {
    @ViewBuilder
    public func focused<Value: hTextFieldFocusStateCompliant>(
        _ focusedField: Binding<Value?>,
        equals: Value,
        onReturn: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(hTextFieldFocusStateModifier(focusedField: focusedField, equals: equals, onReturn: onReturn))
    }
}
