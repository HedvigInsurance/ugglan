import Foundation

@propertyWrapper public struct CachedDefault<T> {
    public init(
        key: String,
        defaultValue: T
    ) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public let key: String
    public let defaultValue: T

    public let storage = UserDefaults.standard

    public var wrappedValue: T {
        get { storage.object(forKey: key) as? T ?? defaultValue }
        set {
            storage.set(newValue, forKey: key)
            storage.synchronize()
        }
    }
}

@propertyWrapper public struct Cached<T> {
    public init(key: String) { self.key = key }

    public let key: String
    public let storage = UserDefaults.standard

    public var wrappedValue: T? {
        get { storage.object(forKey: key) as? T }
        set {
            storage.setValue(newValue, forKey: key)
            storage.synchronize()
        }
    }
}
