import Flow
import Foundation
import UIKit

public func += <SignalKind, SignalValue>(_ bag: DisposeBag, _ signal: CoreSignal<SignalKind, SignalValue>?) {
    bag += signal?.nil()
}

public struct Animated: SignalProvider {
    public typealias Value = Void
    public typealias Kind = Plain

    public var providedSignal: CoreSignal<Plain, Void> { Self.now }

    public static var now: CoreSignal<Plain, Void> { Signal(just: ()) }
}

extension SignalProvider {
    /// explicitly ignore any value emitted by a signal
    public func `nil`() -> Disposable { onValue { _ in } }

    public func bindTo<T>(
        transition view: UIView,
        style: TransitionStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler) { newValue in
            UIView.transition(
                with: view,
                duration: style.duration,
                options: style.options,
                animations: { value[keyPath: keyPath] = newValue },
                completion: nil
            )
        }

        return bag
    }

    public func bindTo<T>(
        animate style: AnimationStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler) { newValue in
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                options: style.options,
                animations: { value[keyPath: keyPath] = newValue },
                completion: nil
            )
        }

        return bag
    }

    public func bindTo<T>(
        animate style: SpringAnimationStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler) { newValue in
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                usingSpringWithDamping: style.damping,
                initialSpringVelocity: style.velocity,
                options: style.options,
                animations: { value[keyPath: keyPath] = newValue },
                completion: nil
            )
        }

        return bag
    }

    public func transition(
        on scheduler: Scheduler = .current,
        style: TransitionStyle,
        with view: UIView,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in
                UIView.transition(
                    with: view,
                    duration: style.duration,
                    options: style.options,
                    animations: { animations(value) },
                    completion: { _ in callback(value) }
                )
            }

            return bag
        }
    }

    public func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> AnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in let style = mapStyle(value)
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

    public func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in let style = mapStyle(value)
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    usingSpringWithDamping: style.damping,
                    initialSpringVelocity: style.velocity,
                    options: style.options,
                    animations: { animations(value) },
                    completion: { _ in callback(value) }
                )
            }

            return bag
        }
    }

    public func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Disposable { animated(on: scheduler, mapStyle: mapStyle, animations: animations).nil() }

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

    public func animated(
        on scheduler: Scheduler = .current,
        style: SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    usingSpringWithDamping: style.damping,
                    initialSpringVelocity: style.velocity,
                    options: style.options,
                    animations: { animations(value) },
                    completion: { _ in callback(value) }
                )
            }

            return bag
        }
    }
}
