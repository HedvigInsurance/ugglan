import Foundation

@propertyWrapper public struct CachedDefault<T> {

    public let key: String
    public let defaultValue: T

    public let storage = UserDefaults.standard

    public var wrappedValue: T {
        get {
            return storage.object(forKey: key) as? T ?? defaultValue
        }
        set {
            storage.set(newValue, forKey: key)
            storage.synchronize()
        }
    }
}

@propertyWrapper public struct Cached<T> {

    public let key: String
    public let storage = UserDefaults.standard

    public var wrappedValue: T? {
        get {
            return storage.object(forKey: key) as? T
        }
        set {
            storage.setValue(newValue, forKey: key)
            storage.synchronize()
        }
    }
}
