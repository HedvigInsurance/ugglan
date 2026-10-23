import Combine
import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

extension EnvironmentValues {
    @Entry public var hTextFieldError: String? = nil
}

extension View {
    public func hTextFieldError(_ message: String?) -> some View {
        environment(\.hTextFieldError, message)
    }
}
@MainActor
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
            field
        }
        nonmutating set {
            field = newValue
        }
    }

    public init(
        wrappedValue: Value?
    ) {
        _field = State(initialValue: wrappedValue)
    }
}

class TextFieldObserver: NSObject, UITextFieldDelegate {
    var onReturnTap: () -> Void = {}
    var onDidEndEditing: () -> Void = {}
    var onBeginEditing: () -> Void = {}
    func textFieldShouldReturn(_: UITextField) -> Bool {
        onReturnTap()
        return true
    }

    func textFieldDidEndEditing(_: UITextField) {
        onDidEndEditing()
    }

    func textFieldDidBeginEditing(_: UITextField) {
        onBeginEditing()
    }
}

extension UITextField {
    @objc func dismissKeyboad() {
        resignFirstResponder()
    }
}

public protocol hTextFieldFocusStateCompliant: Hashable {
    static var last: Self { get }
    var next: Self? { get }
}

extension Bool: hTextFieldFocusStateCompliant {
    public static var last: Bool {
        true
    }

    public var next: Bool? {
        nil
    }
}
