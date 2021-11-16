import Combine
import Foundation
import SwiftUI
import hCore

public struct hTextField: View {
    var masking: Masking
    var placeholder: String
    @State var previousInnerValue: String
    @State private var innerValue: String
    @Binding var value: String

    public init(
        masking: Masking,
        value: Binding<String>
    ) {
        self.masking = masking
        self.placeholder = masking.placeholderText ?? ""
        self._value = value
        self.previousInnerValue = value.wrappedValue
        self.innerValue = value.wrappedValue
    }

    public var body: some View {
        VStack {
            SwiftUI.TextField(placeholder, text: $innerValue)
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
                .frame(minHeight: 40)
            SwiftUI.Divider()
        }
    }
}

struct hTextFieldPreview: PreviewProvider {
    static var previews: some View {
        hTextField(masking: Masking(type: .personalNumber), value: .constant(""))
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnTap()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onDidEndEditing()
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
            }

            onReturn()
        }
        
        observer.onDidEndEditing = {
            focusedField = nil
        }

        if equals.hashValue == Value.last.hashValue {
            textField?.returnKeyType = .done
        } else {
            textField?.returnKeyType = .next
        }
    }

    func body(content: Content) -> some View {
        content.introspectTextField { textField in
            self.textField = textField
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
    public func focused<Value: hTextFieldFocusStateCompliant>(
        _ focusedField: Binding<Value?>,
        equals: Value?,
        onReturn: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(hTextFieldFocusStateModifier(focusedField: focusedField, equals: equals, onReturn: onReturn))
    }
}
