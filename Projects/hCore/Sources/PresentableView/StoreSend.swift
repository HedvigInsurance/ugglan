import Combine
import Flow
import Foundation
import Presentation
import SwiftUI

class ReadSignalSubscription<S: Subscriber, Value>: Subscription where S.Input == Value, S.Failure == Never {
    private var subscriber: S?

    fileprivate var bag: DisposeBag? = DisposeBag()
    fileprivate var signal: ReadSignal<Value>?

    init(
        signal: ReadSignal<Value>,
        subscriber: S
    ) {
        self.subscriber = subscriber

        bag += signal.onValue { value in
            let _ = subscriber.receive(value)
        }
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        subscriber = nil
        self.signal = nil
        self.bag?.dispose()
        self.bag = nil
    }
}

public class ReadSignalPublisher<Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    fileprivate var signal: ReadSignal<Value>

    init(
        signal: ReadSignal<Value>
    ) {
        self.signal = signal
    }
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        let subscription = ReadSignalSubscription(signal: signal, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreSignal where Kind == Read {
    public var publisher: ReadSignalPublisher<Value> {
        ReadSignalPublisher(signal: self)
    }
}

final class StoreObserver<S: Store, E: Equatable>: DynamicProperty, ObservableObject {
    typealias ObjectWillChangePublisher = AnyPublisher<S.State, Never>
    typealias Equater = (_ state: S.State) -> E

    var equater: Equater
    var store: S

    public var objectWillChange: AnyPublisher<S.State, Never> {
        return store.stateSignal
            .distinct({ lhs, rhs in
                self.equater(lhs) == self.equater(rhs)
            })
            .publisher.eraseToAnyPublisher()
    }

    init(
        equater: @escaping Equater
    ) {
        let store: S = globalPresentableStoreContainer.get()
        self.store = store
        self.equater = equater
    }
}

public struct PresentableStoreLens<S: Store, Value: Equatable, Content: View>: View {
    typealias Getter = (_ state: S.State) -> Value
    typealias Setter = (_ value: Value) -> S.Action?

    var getter: Getter
    var setter: Setter

    @ObservedObject var storeObserver: StoreObserver<S, Value>

    var content: (_ value: Value, _ setter: @escaping (_ newValue: Value) -> Void) -> Content

    public init(
        _ storeType: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        setter: @escaping (_ value: Value) -> S.Action?,
        @ViewBuilder _ content: @escaping (_ value: Value, _ setter: @escaping (_ newValue: Value) -> Void) -> Content
    ) {
        self.getter = getter
        self.setter = setter
        self.content = content
        self.storeObserver = StoreObserver(equater: getter)
    }

    public init(
        _ storeType: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        @ViewBuilder _ content: @escaping (_ value: Value) -> Content
    ) {
        self.getter = getter
        self.setter = { _ in nil }
        self.content = { value, _ in content(value) }
        self.storeObserver = StoreObserver(equater: getter)
    }

    public var body: some View {
        content(
            getter(storeObserver.store.stateSignal.value),
            { newValue in
                if let action = setter(newValue) {
                    storeObserver.store.send(action)
                }
            }
        )
    }
}

public protocol Lens: View {
    associatedtype S: Store
    associatedtype Value: Equatable
    associatedtype LensBody: View

    func getter(_ state: S.State) -> Value
    func setter(_ value: Value) -> S.Action?
    func body(_ value: Value, _ setter: (_ value: Value) -> Void) -> LensBody
}

extension Lens {
    public var body: some View {
        PresentableStoreLens(S.self, getter: getter, setter: setter) { value, setter in
            body(value, setter)
        }
    }
    
    public func setter(_ value: Value) -> S.Action? {
        nil
    }
}

extension Store {
    public func sendOnce(_ action: Action) -> some View {
        SendEquatable<Self, Bool>(store: self, equatable: true, action: action)
    }

    public func sendOnChangeOf<E: Equatable>(_ equatable: E, _ action: Action) -> some View {
        SendEquatable<Self, E>(store: self, equatable: equatable, action: action)
    }
}

struct SendEquatable<S: Store, E: Equatable>: View {
    var store: S
    var equatable: E
    var action: S.Action

    public var body: some View {
        Color.clear.onReceive(Just(equatable)) { _ in
            store.send(action)
        }
    }
}
