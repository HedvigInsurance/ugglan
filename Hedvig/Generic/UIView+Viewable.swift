//
//  UIView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

private let defaultOnCreateClosure: (_ view: UIView) -> Void = { _ in }

extension UIView {
    // swiftlint:disable large_tuple
    func materializeViewable<V: Viewable, VMatter: UIView>(
        viewable: V,
        onSelectCallbacker: Callbacker<Void> = Callbacker<Void>()
    ) -> (V.Matter, V.Result, DelayedDisposer) where V.Matter == VMatter {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            onSelectCallbacker: onSelectCallbacker
        )
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addSubview(matter)

        wasAddedCallbacker.callAll()

        return (matter, result, DelayedDisposer(Disposer {
            matter.removeFromSuperview()
        }, delay: viewableEvents.removeAfter.call() ?? 0.0))
    }

    // swiftlint:enable large_tuple

    func add<V: Viewable, VMatter: UIView, FutureResult: Any>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == VMatter, V.Result == Future<FutureResult> {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        let bag = DisposeBag()

        bag += result.onResult { _ in
            disposable.dispose()
            bag.dispose()
        }

        return result
    }

    func add<V: Viewable, VMatter: UIView>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == VMatter, V.Result == Disposable {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }

    func add<V: Viewable, VMatter: UIView, SignalType: Any>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == VMatter, V.Result == Signal<SignalType> {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        let bag = DisposeBag()
        bag += disposable

        return Signal { callback in
            bag += result.onValue(callback)
            return bag
        }
    }
}

extension UIStackView {
    // swiftlint:disable large_tuple
    private func materializeArrangedViewable<V: Viewable>(
        viewable: V
    ) -> (V.Matter, V.Result, Disposable) where V.Matter == UIView {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            onSelectCallbacker: Callbacker<Void>()
        )
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addArrangedSubview(matter)

        wasAddedCallbacker.callAll()

        return (matter, result, Disposer {
            matter.removeFromSuperview()
        })
    }

    // swiftlint:enable large_tuple

    func addArangedSubview<V: Viewable>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == UIView, V.Result == Disposable {
        let (matter, result, disposable) = materializeArrangedViewable(viewable: viewable)

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }
}
