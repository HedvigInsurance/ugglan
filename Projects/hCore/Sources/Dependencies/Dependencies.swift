import Apollo
import Combine
import Foundation
import SwiftUICore

@MainActor
public class Dependencies {
    public static var shared = Dependencies()
    private var modules = [String: Module]()

    private init() {}
    deinit { modules.removeAll() }

    public func add(module: Module) { modules[module.name] = module }

    public func resolve<T>(for name: String? = nil) -> T {
        let name = name ?? String(describing: T.self)

        guard let component: T = modules[name]?.resolve() as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }

        return component
    }

    public func remove<T>(for: T.Type) {
        modules.removeValue(forKey: String(describing: T.self))
    }
}

@MainActor
public struct Module {
    fileprivate let name: String
    fileprivate let resolve: () -> Any

    public init<T>(
        _ name: String? = nil,
        _ resolve: @escaping () -> T
    ) {
        self.name = name ?? String(describing: T.self)
        self.resolve = resolve
    }
}

/// Resolves an instance from the dependency injection container.
@MainActor
@propertyWrapper public struct Inject<Value> {
    private let name: String?

    public var wrappedValue: Value {
        Dependencies.shared.resolve(for: name)
    }

    public init() { name = nil }

    public init(_ name: String) { self.name = name }
}

@MainActor
@propertyWrapper
public struct InjectObservableObject<T: ObservableObject>: DynamicProperty {
    @StateObject private var stateObject: T

    public init() {

        _stateObject = StateObject(wrappedValue: Dependencies.shared.resolve())
    }

    public var wrappedValue: T {
        stateObject
    }

    public var projectedValue: ObservedObject<T>.Wrapper {
        return $stateObject
    }
}
