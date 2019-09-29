//
//  CoreSignal+Animation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension SignalProvider {
    /// explicitly ignore any value emitted by a signal
    func `nil`() -> Disposable {
        self.onValue { _ in }
    }
    
    func bindTo<T>(
        transition view: UIView,
        style: TransitionStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler) { newValue in
            UIView.transition(with: view, duration: style.duration, options: style.options, animations: {
                value[keyPath: keyPath] = newValue
            }, completion: nil)
        }

        return bag
    }

    func bindTo<T>(
        animate style: AnimationStyle,
        on scheduler: Scheduler = .current,
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> Disposable {
        let bag = DisposeBag()

        bag += bindTo(on: scheduler) { newValue in
            UIView.animate(withDuration: style.duration, delay: style.delay, options: style.options, animations: {
                value[keyPath: keyPath] = newValue
            }, completion: nil)
        }

        return bag
    }

    func bindTo<T>(
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
                animations: {
                    value[keyPath: keyPath] = newValue
                },
                completion: nil
            )
        }

        return bag
    }

    func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> AnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in
            let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in
                let style = mapStyle(value)
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    options: style.options,
                    animations: {
                        animations(value)
                    },
                    completion: { _ in
                        callback(value)
                    }
                )
            }
            
            return bag
        }
    }
    
    func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> AnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Disposable {
        animated(on: scheduler, mapStyle: mapStyle, animations: animations).nil()
    }

    func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in
            let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in
                let innerBag = DisposeBag()
                let style = mapStyle(value)
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    usingSpringWithDamping: style.damping,
                    initialSpringVelocity: style.velocity,
                    options: style.options,
                    animations: {
                        animations(value)
                    },
                    completion: { _ in
                        innerBag.dispose()
                        callback(value)
                    }
                )
            }
            
            return bag
        }
    }
    
    func animated(
        on scheduler: Scheduler = .current,
        mapStyle: @escaping (_ value: Value) -> SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Disposable {
        animated(on: scheduler, mapStyle: mapStyle, animations: animations).nil()
    }

    func animated(
        on scheduler: Scheduler = .current,
        style: AnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in
            let bag = DisposeBag()
            
            bag += self.onValue(on: scheduler) { value in
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    options: style.options,
                    animations: {
                        animations(value)
                    },
                    completion: { _ in
                        callback(value)
                    }
                )
            }
            return bag
        }
    }
    
    func animated(
        on scheduler: Scheduler = .current,
        style: AnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Disposable {
        animated(on: scheduler, style: style, animations: animations).nil()
    }

    func animated(
        on scheduler: Scheduler = .current,
        style: SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Signal<Value> {
        Signal<Value> { callback in
            let bag = DisposeBag()

            bag += self.onValue(on: scheduler) { value in
                UIView.animate(
                    withDuration: style.duration,
                    delay: style.delay,
                    usingSpringWithDamping: style.damping,
                    initialSpringVelocity: style.velocity,
                    options: style.options,
                    animations: {
                        animations(value)
                    },
                    completion: { _ in
                        callback(value)
                    }
                )
            }
            
            return bag
        }
    }
    
    func animated(
        on scheduler: Scheduler = .current,
        style: SpringAnimationStyle,
        animations: @escaping (_ value: Value) -> Void
    ) -> Disposable {
        animated(on: scheduler, style: style, animations: animations).nil()
    }
}
