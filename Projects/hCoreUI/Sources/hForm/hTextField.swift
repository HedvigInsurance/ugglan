import Foundation
import SwiftUI
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

extension UITextField {
    @objc func dismissKeyboad() {
        resignFirstResponder()
    }
}
