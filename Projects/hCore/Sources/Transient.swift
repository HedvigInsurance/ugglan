import Foundation

@propertyWrapper
public struct Transient<Value>: Codable & Equatable & Sendable where Value: Codable & Equatable & Sendable {
    public var wrappedValue: Value {
        get {
            innerValue ?? defaultValue
        }
        set {
            innerValue = newValue
        }
    }

    public var innerValue: Value?
    public var defaultValue: Value

    public init(
        wrappedValue: Value?,
        defaultValue: Value
    ) {
        self.defaultValue = defaultValue
        innerValue = wrappedValue
    }

    public init(
        defaultValue: Value
    ) {
        self.defaultValue = defaultValue
        innerValue = nil
    }

    enum CodingKeys: CodingKey {
        case defaultValue
    }
}

@propertyWrapper
public struct OptionalTransient<Value>: Codable & Equatable & Sendable where Value: Codable & Equatable & Sendable {
    public var wrappedValue: Value? {
        get {
            innerValue
        }
        set {
            innerValue = newValue
        }
    }

    public var innerValue: Value?

    public init(
        wrappedValue: Value?
    ) {
        innerValue = wrappedValue
    }

    enum CodingKeys: CodingKey {}
}
