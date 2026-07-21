import Combine
import Foundation
import SwiftUI

@MainActor
public protocol AppStore: ObservableObject {
    init()
}

@MainActor
public protocol PersistableAppStore: AppStore {
    associatedtype Snapshot: Codable & Sendable
    var snapshot: Snapshot { get }
    func apply(snapshot: Snapshot)
}

@MainActor
public final class AppStateContainer {
    private var stores: [ObjectIdentifier: AnyObject] = [:]
    private var persistenceCancellables: [ObjectIdentifier: AnyCancellable] = [:]

    public nonisolated init() {}

    public func get<S: AppStore>() -> S {
        get(S.self)
    }

    public func get<S: AppStore>(_: S.Type) -> S {
        let key = ObjectIdentifier(S.self)
        if let existing = stores[key] as? S {
            return existing
        }
        let store = S()
        stores[key] = store
        attachPersistence(store)
        return store
    }

    public func register<S: AppStore>(_ store: S) {
        let key = ObjectIdentifier(S.self)
        persistenceCancellables[key] = nil
        stores[key] = store
        attachPersistence(store)
    }

    public func reset() {
        stores.removeAll()
        persistenceCancellables.removeAll()
    }

    public func clearPersistence(preserving preserved: [any AppStore.Type] = []) {
        let preservedNames = Set(preserved.map { String(describing: $0) })
        if preservedNames.isEmpty {
            try? FileManager.default.removeItem(at: Self.directory)
        } else {
            let contents =
                (try? FileManager.default.contentsOfDirectory(
                    at: Self.directory,
                    includingPropertiesForKeys: nil
                )) ?? []
            for file in contents where !preservedNames.contains(file.lastPathComponent) {
                try? FileManager.default.removeItem(at: file)
            }
        }
        // Also wipe the old PresentableStore directory so logged-out users don't keep
        // pre-migration snapshots on disk after `restore` has already drained them.
        // Preserved stores are new-directory-only, so no exclusions are needed here.
        try? FileManager.default.removeItem(at: Self.legacyDirectory)
    }

    private func attachPersistence<S: AppStore>(_ store: S) {
        guard let persistable = store as? any PersistableAppStore else { return }
        restore(persistable)
        observe(persistable)
    }

    private func restore<S: PersistableAppStore>(_ store: S) {
        let data =
            (try? Data(contentsOf: Self.url(for: S.self)))
            ?? (try? Data(contentsOf: Self.legacyURL(for: S.self)))
        guard
            let data,
            let snapshot = try? JSONDecoder().decode(S.Snapshot.self, from: data)
        else { return }
        store.apply(snapshot: snapshot)
    }

    private func observe<S: PersistableAppStore>(_ store: S) {
        let key = ObjectIdentifier(S.self)
        let url = Self.url(for: S.self)
        persistenceCancellables[key] = store.objectWillChange
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak store] _ in
                guard let store else { return }
                let snapshot = store.snapshot
                Task.detached(priority: .background) {
                    Self.persist(snapshot, to: url)
                }
            }
    }

    private nonisolated static func persist<Snapshot: Encodable & Sendable>(_ snapshot: Snapshot, to url: URL) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: url)
    }

    nonisolated static var directory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AppStateContainer")
    }

    nonisolated static func url<S: PersistableAppStore>(for _: S.Type) -> URL {
        directory.appendingPathComponent(String(describing: S.self))
    }

    nonisolated static var legacyDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PresentableStore")
    }

    nonisolated static func legacyURL<S: PersistableAppStore>(for _: S.Type) -> URL {
        legacyDirectory.appendingPathComponent(String(describing: S.self))
    }
}

@MainActor
public var globalAppStateContainer = AppStateContainer()

@MainActor
@propertyWrapper
public struct AppObservedObject<T: AppStore>: DynamicProperty {
    @StateObject private var stateObject: T
    public init() {
        _stateObject = StateObject(wrappedValue: globalAppStateContainer.get())
    }

    public var wrappedValue: T {
        stateObject
    }

    public var projectedValue: ObservedObject<T>.Wrapper {
        $stateObject
    }
}

@propertyWrapper
@MainActor
public struct AppState<S: AppStore> {
    public var wrappedValue: S { globalAppStateContainer.get() }
    public init() {}
}

@attached(
    extension,
    conformances: PersistableAppStore,
    names: named(Snapshot),
    named(snapshot),
    named(apply)
)
public macro PersistableStore() =
    #externalMacro(module: "AppStateContainerMacros", type: "PersistableStoreMacro")

@attached(peer)
public macro Transient() =
    #externalMacro(module: "AppStateContainerMacros", type: "TransientMacro")
