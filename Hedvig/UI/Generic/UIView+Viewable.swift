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
    // swiftlint:disable large-tuple
    private func materializeViewable<V: Viewable>(
        viewable: V
    ) -> (V.Matter, V.Result, Disposable) where V.Matter == UIView {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        )
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addSubview(matter)

        wasAddedCallbacker.callAll()

        return (matter, result, Disposer {
            matter.removeFromSuperview()
        })
    }

    // swiftlint:enable large-tuple

    func add<V: Viewable, FutureResult: Any>(
        _ viewable: V,
        onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == UIView, V.Result == Future<FutureResult> {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        let bag = DisposeBag()

        bag += result.onResult { _ in
            disposable.dispose()
            bag.dispose()
        }

        return result
    }

    func add<V: Viewable>(
        _ viewable: V,
        onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == UIView, V.Result == Disposable {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }

    func add<V: Viewable, SignalType: Any>(
        _ viewable: V,
        onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == UIView, V.Result == Signal<SignalType> {
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
    // swiftlint:disable large-tuple
    private func materializeArrangedViewable<V: Viewable>(
        viewable: V
    ) -> (V.Matter, V.Result, Disposable) where V.Matter == UIView {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        )
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addArrangedSubview(matter)

        wasAddedCallbacker.callAll()

        return (matter, result, Disposer {
            matter.removeFromSuperview()
        })
    }

    // swiftlint:enable large-tuple

    func addArangedSubview<V: Viewable>(
        _ viewable: V,
        onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == UIView, V.Result == Disposable {
        let (matter, result, disposable) = materializeArrangedViewable(viewable: viewable)

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }
}
