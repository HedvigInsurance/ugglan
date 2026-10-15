import Apollo
import Combine
import Foundation
import Observation
import SwiftUI

@MainActor
public class Dependencies {
    public static var shared = Dependencies()
    private var modules = [String: Module]()

    private init() {}
    deinit { modules.removeAll() }

    public func add(module: Module) {
        modules[module.name] = module
    }

    public func resolve<T>(for name: String? = nil) -> T {
        let name = name ?? String(describing: T.self)

        guard let component: T = modules[name]?.resolve() as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }

        return component
    }

    public func remove<T>(for _: T.Type) {
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
public struct InjectObservableObject<T: AnyObject & Observable>: DynamicProperty {
    /// `State(wrappedValue:)` evaluates its argument eagerly, unlike the autoclosure `StateObject` took,
    /// so resolving in `init` would run before e.g. `MainNavigation.init` has registered the dependency.
    /// The box defers resolution to first access and keeps that instance for the view's lifetime.
    @State private var box = LazyResolvedBox<T>()

    public init() {}

    public var wrappedValue: T {
        box.object
    }

    public var projectedValue: Bindable<T> {
        Bindable(box.object)
    }
}

@MainActor
private final class LazyResolvedBox<T: AnyObject> {
    lazy var object: T = Dependencies.shared.resolve()
}
