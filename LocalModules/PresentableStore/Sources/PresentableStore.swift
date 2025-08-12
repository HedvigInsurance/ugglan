@preconcurrency import Combine
import Foundation

@propertyWrapper
@MainActor
public struct PresentableStore<S: Store> {
    public var wrappedValue: S { globalPresentableStoreContainer.get() }

    public init() {}
}

public protocol EmptyInitable {
    init()
}

public protocol StateProtocol: Codable & EmptyInitable & Equatable & Sendable {}
public protocol ActionProtocol: Codable & Equatable & Sendable {}

@globalActor public actor StoreActor {
    public static let shared = StoreActor()
}

open class StateStore<State: StateProtocol, Action: ActionProtocol>: Store where State: Sendable, Action: Sendable {
    let stateWriteSignal: CurrentValueSubject<State, Never>
    let actionCallbacker: PassthroughSubject<Action, Never> = .init()
    private var lastTimeSaved: Date?
    public var logger: @Sendable (_ message: String) -> Void = { _ in }

    public var state: State {
        stateWriteSignal.value
    }

    public var stateSignal: AnyPublisher<State, Never> {
        stateWriteSignal.eraseToAnyPublisher()
    }

    public var actionSignal: AnyPublisher<Action, Never> {
        actionCallbacker.eraseToAnyPublisher()
    }

    open func effects(_: @escaping () -> State, _: Action) async {
        fatalError("Must be overrided by subclass")
    }

    open func reduce(_: State, _: Action) async -> State {
        fatalError("Must be overrided by subclass")
    }

    public func setState(_ state: State) {
        stateWriteSignal.value = state
    }

    private nonisolated func getQueue() -> DispatchQueue {
        DispatchQueue(label: "quoue.\(String(describing: self))", qos: .default)
    }

    /// Sends an action to the store, which is then reduced to produce a new state
    public func send(_ action: Action) {
        Task { [weak self] in
            guard let self else { return }
            await withCheckedContinuation { continuation in
                self.enqueueSend(action, continuation: continuation)
            }
        }
    }

    nonisolated private func enqueueSend(
        _ action: Action,
        continuation: CheckedContinuation<Void, Never>
    ) {
        getQueue()
            .async { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                Task { [weak self] in
                    guard let self else {
                        continuation.resume()
                        return
                    }
                    await self.sendAsync(action)
                    continuation.resume()
                }
            }
    }

    //    public func send(_ action: Action) {
    //        Task { [weak self] in
    //            await withCheckedContinuation {
    //                (inCont: CheckedContinuation<Void, Never>) in
    //                self?.getQueue()
    //                    .async { [weak self] in
    //                        guard let self = self else { return }
    //                        let semaphore = DispatchSemaphore(value: 0)
    //                        Task { [weak self] in
    //                            guard let self else {
    //                                semaphore.signal()
    //                                return
    //                            }
    //                            await self.sendAsync(action)
    //                            semaphore.signal()
    //                        }
    //                        semaphore.wait()
    //                        inCont.resume()
    //                    }
    //            }
    //        }
    //    }

    public func sendAsync(_ action: Action) async {
        await logger("🦄 \(String(describing: Self.self)): sending \(action)")
        let task = Task { @MainActor in
            let previousState = stateWriteSignal.value
            stateWriteSignal.value = await reduce(stateWriteSignal.value, action)
            actionCallbacker.send(action)
            let newState = stateWriteSignal.value

            if newState != previousState {
                logger("🦄 \(String(describing: Self.self)): new state \n \(newState)")
                let value = self.stateWriteSignal.value
                DispatchQueue.global(qos: .background)
                    .async {
                        Self.persist(value)
                    }
            }
            await effects(
                {
                    self.stateWriteSignal.value
                },
                action
            )
        }
        await task.value
    }

    public required init() {
        if let stored = Self.restore() {
            stateWriteSignal = .init(stored)
        } else {
            stateWriteSignal = .init(State())
        }
    }
}

@MainActor
public protocol Store {
    associatedtype State: StateProtocol
    associatedtype Action: ActionProtocol

    @MainActor
    static func getKey() -> UnsafeMutablePointer<Int>

    @MainActor
    var logger: @Sendable (_ message: String) -> Void { get set }
    var state: State { get }
    var stateSignal: AnyPublisher<State, Never> { get }
    var actionSignal: AnyPublisher<Action, Never> { get }

    /// WARNING: Use this to set the state to the provided state BUT only for mocking purposes
    func setState(_ state: State)

    @MainActor
    func reduce(_ state: State, _ action: Action) async -> State
    @MainActor
    func effects(_ getState: @escaping () -> State, _ action: Action) async
    nonisolated func send(_ action: Action)
    @StoreActor
    func sendAsync(_ action: Action) async

    init()
}

@MainActor
var pointers: [String: UnsafeMutablePointer<Int>] = [:]

var storePersistenceDirectory: URL {
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory.appendingPathComponent("PresentableStore")
}

extension Store {
    @MainActor
    public static func getKey() -> UnsafeMutablePointer<Int> {
        let key = String(describing: Self.self)

        if pointers[key] == nil {
            pointers[key] = UnsafeMutablePointer<Int>.allocate(capacity: 2)
        }

        return pointers[key]!
    }

    internal nonisolated static var persistenceURL: URL {
        let docURL = storePersistenceDirectory
        try? FileManager.default.createDirectory(at: docURL, withIntermediateDirectories: true, attributes: nil)
        return docURL.appendingPathComponent(String(describing: Self.self))
    }

    public nonisolated static func persist(_ value: State) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            do {
                try encoded.write(to: persistenceURL)
            } catch {
                print("Couldn't write to save file: " + error.localizedDescription)
            }
        }
    }

    public static func restore() -> State? {
        guard let codedData = try? Data(contentsOf: persistenceURL) else {
            return nil
        }

        let decoder = JSONDecoder()

        if let decoded = try? decoder.decode(State.self, from: codedData) {
            return decoded
        }

        return nil
    }

    /// Deletes all persisted instances of the Store
    public static func destroy() {
        try? FileManager.default.removeItem(at: persistenceURL)
    }

    /// Reduce to an action in another store, useful to sync between two stores
    //    public func reduce<S: hStore>(to store: S, reducer: @escaping (_ action: Action, _ state: State) -> S.Action) -> Disposable {
    //        actionSignal.onValue { action in
    //            store.send(reducer(action, stateSignal.value))
    //        }
    //    }
    //
    //    /// Calls onAction whenever an action equal to action happens
    //    public func onAction(_ action: Action, _ onAction: @escaping () -> Void) -> Disposable {
    //        actionSignal.filter(predicate: { action == $0 }).onValue { action in
    //            onAction()
    //        }
    //    }
}

public protocol Debugger {
    func startServer()
    func registerStore<S: Store>(_ store: S)
}

@MainActor
public class PresentableStoreContainer: NSObject {
    public func get<S: Store>() -> S {
        if let store: S = associatedValue(forKey: S.getKey()) {
            return store
        }

        var store = S()
        store.logger = logger
        initialize(store)

        return store
    }

    public func get<S: Store>(of _: S.Type) -> S {
        let store: S = get()
        return store
    }

    public func initialize<S: Store>(_ store: S) {
        setAssociatedValue(store, forKey: S.getKey())
        debugger?.registerStore(store)
    }

    override public init() {
        super.init()
    }

    public func deletePersistanceContainer() {
        try? FileManager.default.removeItem(at: storePersistenceDirectory)
    }

    public var debugger: Debugger?
    public var logger: @Sendable (_ message: String) -> Void = { message in
        print(message)
    }
}

/// Set this to automatically populate all presentables with your global PresentableStoreContainer
@MainActor
public var globalPresentableStoreContainer = PresentableStoreContainer()

public protocol LoadingProtocol: Codable & Equatable & Hashable & Sendable {}

public enum LoadingState<T>: Codable & Equatable & Hashable & Sendable
where T: Codable & Equatable & Hashable & Sendable {
    case loading
    case error(error: T)
}

@MainActor
public protocol StoreLoading {
    associatedtype Loading: LoadingProtocol
    var loadingState: [Loading: LoadingState<String>] { get }
    var loadingSignal: AnyPublisher<[Loading: LoadingState<String>], Never> { get }
    func removeLoading(for action: Loading)

    func setLoading(for action: Loading)

    func setError(_ error: String, for action: Loading)

    func reset()

    init()
}

@MainActor
open class LoadingStateStore<State: StateProtocol, Action: ActionProtocol, Loading: LoadingProtocol>: StateStore<
    State, Action
>, StoreLoading
where State: Sendable, Action: Sendable {
    public var loadingState: [Loading: LoadingState<String>] {
        loadingStates
    }

    private var loadingStates: [Loading: LoadingState<String>] = [:] {
        didSet {
            loadingWriteSignal.value = loadingStates
        }
    }

    private let loadingWriteSignal = CurrentValueSubject<[Loading: LoadingState<String>], Never>([:])

    public var loadingSignal: AnyPublisher<[Loading: LoadingState<String>], Never> {
        loadingWriteSignal.removeDuplicates().eraseToAnyPublisher()
    }

    public func removeLoading(for action: Loading) {
        loadingStates.removeValue(forKey: action)
    }

    public func setLoading(for action: Loading) {
        loadingStates[action] = .loading
    }

    public func setError(_ error: String, for action: Loading) {
        loadingStates[action] = .error(error: error)
    }

    public func reset() {
        loadingStates.removeAll()
    }

    public required init() {
        super.init()
    }
}

enum PresentableStoreError: Error {
    case notImplemented
}

extension NSObject {
    func associatedValue<T>(forKey key: UnsafeRawPointer) -> T? {
        objc_getAssociatedObject(self, key) as? T
    }

    func associatedValue<T>(forKey key: UnsafeRawPointer, initial: @autoclosure () throws -> T) rethrows -> T {
        if let val: T = associatedValue(forKey: key) {
            return val
        }
        let val = try initial()
        setAssociatedValue(val, forKey: key)
        return val
    }

    func setAssociatedValue<T>(_ val: T?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, val, .OBJC_ASSOCIATION_RETAIN)
    }

    func clearAssociatedValue(forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, nil, .OBJC_ASSOCIATION_RETAIN)
    }
}
