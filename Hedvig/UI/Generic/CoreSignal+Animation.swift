//
//  CoreSignal+Animation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

struct AnimatedSignal<Value>: SignalProvider {
    let providedSignal: Signal<Value>
    let providedDisposable: Disposable

    func disposable() -> Disposable {
        return providedDisposable
    }
}

extension SignalProvider {
    func bindTo<T>(
        transition view: UIView,
        style: TransitionStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler, { newValue in
            UIView.transition(with: view, duration: style.duration, options: style.options, animations: {
                value[keyPath: keyPath] = newValue
            }, completion: nil)
        })

        return bag
    }

    func bindTo<T>(
        animate style: AnimationStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler, { newValue in
            UIView.animate(withDuration: style.duration, delay: style.delay, options: style.options, animations: {
                value[keyPath: keyPath] = newValue
            }, completion: nil)
        })

        return bag
    }

    func animated(
        mapStyle: @escaping (_ value: Value) -> AnimationStyle,
        animations: @escaping () -> Void
    ) -> AnimatedSignal<Value> {
        let callbacker = Callbacker<Value>()
        let bag = DisposeBag()

        bag += onValue { value in
            let style = mapStyle(value)
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                options: style.options,
                animations: animations,
                completion: { _ in
                    bag.dispose()
                    callbacker.callAll(with: value)
                }
            )
        }

        let animatedSignal = AnimatedSignal(providedSignal: callbacker.signal(), providedDisposable: bag)
        return animatedSignal
    }

    func animated(
        mapStyle: @escaping (_ value: Value) -> SpringAnimationStyle,
        animations: @escaping () -> Void
    ) -> AnimatedSignal<Value> {
        let callbacker = Callbacker<Value>()
        let bag = DisposeBag()

        bag += onValue { value in
            let style = mapStyle(value)
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                usingSpringWithDamping: style.damping,
                initialSpringVelocity: style.velocity,
                options: [],
                animations: animations,
                completion: { _ in
                    bag.dispose()
                    callbacker.callAll(with: value)
                }
            )
        }

        let animatedSignal = AnimatedSignal(providedSignal: callbacker.signal(), providedDisposable: bag)
        return animatedSignal
    }

    func animated(
        style: AnimationStyle,
        animations: @escaping () -> Void
    ) -> AnimatedSignal<Value> {
        let callbacker = Callbacker<Value>()

        let bag = DisposeBag()

        bag += onValue { value in
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                options: style.options,
                animations: animations,
                completion: { _ in
                    bag.dispose()
                    callbacker.callAll(with: value)
                }
            )
        }

        let animatedSignal = AnimatedSignal(providedSignal: callbacker.signal(), providedDisposable: bag)
        return animatedSignal
    }

    func animated(
        style: SpringAnimationStyle,
        animations: @escaping () -> Void
    ) -> AnimatedSignal<Value> {
        let callbacker = Callbacker<Value>()

        let bag = DisposeBag()

        bag += onValue { value in
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                usingSpringWithDamping: style.damping,
                initialSpringVelocity: style.velocity,
                options: [],
                animations: animations,
                completion: { _ in
                    bag.dispose()
                    callbacker.callAll(with: value)
                }
            )
        }

        let animatedSignal = AnimatedSignal(providedSignal: callbacker.signal(), providedDisposable: bag)
        return animatedSignal
    }
}
