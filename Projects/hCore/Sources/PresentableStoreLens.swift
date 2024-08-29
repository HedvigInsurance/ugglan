import Combine
import Flow
import Foundation
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
