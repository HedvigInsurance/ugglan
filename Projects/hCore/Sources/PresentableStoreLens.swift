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
    typealias ObservedPart = (_ state: S.State) -> E

    var observedPart: ObservedPart
    var store: S

    public var objectWillChange: AnyPublisher<S.State, Never> {
        return store.stateSignal
            .distinct({ lhs, rhs in
                self.observedPart(lhs) == self.observedPart(rhs)
            })
            .publisher.eraseToAnyPublisher()
    }

    init(
        observedPart: @escaping ObservedPart
    ) {
        let store: S = globalPresentableStoreContainer.get()
        self.store = store
        self.observedPart = observedPart
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
        self.storeObserver = StoreObserver(observedPart: getter)
    }

    public init(
        _ storeType: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        @ViewBuilder _ content: @escaping (_ value: Value) -> Content
    ) {
        self.getter = getter
        self.setter = { _ in nil }
        self.content = { value, _ in content(value) }
        self.storeObserver = StoreObserver(observedPart: { state in
            getter(state)
        })
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
