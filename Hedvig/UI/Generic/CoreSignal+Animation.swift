//
//  CoreSignal+Animation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import INTUAnimationEngine

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
        style: AnimationStyle,
        animateClosure: @escaping () -> Void
    ) -> Signal<Void> {
        let callbacker = Callbacker<Void>()

        let bag = DisposeBag()

        bag += onValue { _ in
            UIView.animate(
                withDuration: style.duration,
                delay: style.delay,
                options: style.options,
                animations: animateClosure,
                completion: { _ in
                    bag.dispose()
                    callbacker.callAll()
                }
            )
        }

        return callbacker.signal()
    }

    func animated(
        style: SpringAnimationStyle,
        animateClosure: @escaping (_ progress: CGFloat) -> Void
    ) -> Signal<Void> {
        let callbacker = Callbacker<Void>()

        let bag = DisposeBag()

        bag += onValue { _ in
            INTUAnimationEngine.animate(
                withDamping: style.damping,
                stiffness: style.stiffness,
                mass: style.mass,
                delay: style.delay,
                animations: animateClosure,
                completion: { _ in
                    bag.dispose()
                    callbacker.callAll()
                }
            )
        }

        return callbacker.signal()
    }
}
