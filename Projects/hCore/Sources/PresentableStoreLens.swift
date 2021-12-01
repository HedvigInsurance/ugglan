import Combine
import Flow
import Foundation
import Presentation
import SwiftUI

class SignalSubscription<S: Subscriber, Value>: Subscription where S.Input == Value, S.Failure == Never {
    private var subscriber: S?

    fileprivate var bag: DisposeBag? = DisposeBag()
    fileprivate var signal: Signal<Value>?

    init(
        signal: Signal<Value>,
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

public class SignalPublisher<Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    fileprivate var signal: Signal<Value>

    init(
        signal: Signal<Value>
    ) {
        self.signal = signal
    }

    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        let subscription = SignalSubscription(signal: signal, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreSignal where Kind == Plain {
    public var publisher: SignalPublisher<Value> {
        SignalPublisher(signal: self)
    }
}

public struct PresentableStoreLens<S: Store, Value: Equatable, Content: View>: View {
    typealias Getter = (_ state: S.State) -> Value
    typealias Setter = (_ value: Value) -> S.Action?

    @Environment(\.presentableStoreLensAnimation) var animation
    @State var value: Value
    var getter: Getter
    var setter: Setter

    var store: S

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

        let store: S = globalPresentableStoreContainer.get()
        self.store = store

        self._value = State(initialValue: getter(store.stateSignal.value))
    }

    public init(
        _ storeType: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        @ViewBuilder _ content: @escaping (_ value: Value) -> Content
    ) {
        self.getter = getter
        self.setter = { _ in nil }
        self.content = { value, _ in content(value) }

        let store: S = globalPresentableStoreContainer.get()
        self.store = store

        self._value = State(initialValue: getter(store.stateSignal.value))
    }

    public var body: some View {
        content(
            value,
            { newValue in
                if let action = setter(newValue) {
                    store.send(action)
                }
            }
        )
        .onReceive(
            store.stateSignal
                .plain()
                .distinct({ lhs, rhs in
                    self.getter(lhs) == self.getter(rhs)
                })
                .publisher
        ) { _ in
            if let animation = animation {
                withAnimation(animation) {
                    self.value = getter(store.stateSignal.value)
                }
            } else {
                self.value = getter(store.stateSignal.value)
            }
        }
    }
}

private struct EnvironmentPresentableStoreLensAnimation: EnvironmentKey {
    static let defaultValue: Animation? = nil
}

extension EnvironmentValues {
    public var presentableStoreLensAnimation: Animation? {
        get { self[EnvironmentPresentableStoreLensAnimation.self] }
        set { self[EnvironmentPresentableStoreLensAnimation.self] = newValue }
    }
}

extension View {
    public func presentableStoreLensAnimation(_ animation: Animation?) -> some View {
        self.environment(\.presentableStoreLensAnimation, animation)
    }
}
