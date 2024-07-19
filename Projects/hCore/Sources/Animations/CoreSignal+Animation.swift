import Flow
import Foundation
import SwiftUI

public func += <SignalKind, SignalValue>(_ bag: DisposeBag, _ signal: CoreSignal<SignalKind, SignalValue>?) {
    bag += signal?.nil()
}

extension SignalProvider {
    /// explicitly ignore any value emitted by a signal
    public func `nil`() -> Disposable { onValue { _ in } }

    public func animated(
        on scheduler: Scheduler = .current,
        style: AnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    options: style.options,
                    animations: { animations(value) },
                    completion: { _ in callback(value) }
                )
            }
            return bag
        }
    }
}
