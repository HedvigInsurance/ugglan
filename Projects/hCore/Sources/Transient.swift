import Foundation
@propertyWrapper
public struct Transient<Value>: Codable & Equatable where Value: Codable & Equatable {
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
        
    public init(wrappedValue: Value?, defaultValue: Value) {
        self.defaultValue = defaultValue
        self.innerValue = wrappedValue
    }
    
    public init(defaultValue: Value) {
        self.defaultValue = defaultValue
        self.innerValue = nil
    }
    
    enum CodingKeys: CodingKey {
        case defaultValue
    }
}

@propertyWrapper
public struct OptionalTransient<Value>: Codable & Equatable where Value: Codable & Equatable {
    public var wrappedValue: Value? {
        get {
            innerValue
        }
        set {
            innerValue = newValue
        }
    }
    public var innerValue: Value?
        
    public init(wrappedValue: Value?) {
        self.innerValue = wrappedValue
    }
    
    enum CodingKeys: CodingKey {}
}
