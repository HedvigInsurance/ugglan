import Flow
import Foundation
import UIKit

public let defaultOnCreateClosure: (_ view: UIView) -> Void = { _ in }

extension UIView {
    // swiftlint:disable large_tuple
    public func materializeViewable<V: Viewable, VMatter: UIView>(
        viewable: V
    ) -> (V.Matter, V.Result, DelayedDisposer) where V.Matter == VMatter, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let viewableEvents = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)

        let (matter, result) = viewable.materialize(events: viewableEvents)

        addSubview(matter)

        wasAddedCallbacker.callAll()

        return (
            matter, result,
            DelayedDisposer(
                Disposer { matter.removeFromSuperview() },
                delay: viewableEvents.removeAfter.call() ?? 0.0
            )
        )
    }

    public func materializeViewable<V: Viewable, VMatter: UIView>(
        viewable: V,
        addView: (_ view: VMatter) -> Void
    ) -> (V.Matter, V.Result, DelayedDisposer) where V.Matter == VMatter, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addView(matter)

        wasAddedCallbacker.callAll()

        return (
            matter, result,
            DelayedDisposer(
                Disposer { matter.removeFromSuperview() },
                delay: viewableEvents.removeAfter.call() ?? 0.0
            )
        )
    }

    public func materializeViewable<V: Viewable, VMatter: UIView>(
        viewable: V,
        onSelectCallbacker: Callbacker<Void>
    ) -> (V.Matter, V.Result, DelayedDisposer) where V.Matter == VMatter, V.Events == SelectableViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = SelectableViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            onSelectCallbacker: onSelectCallbacker
        )
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addSubview(matter)

        wasAddedCallbacker.callAll()

        return (
            matter, result,
            DelayedDisposer(
                Disposer { matter.removeFromSuperview() },
                delay: viewableEvents.removeAfter.call() ?? 0.0
            )
        )
    }

    // swiftlint:enable large_tuple

    public func add<V: Viewable, VMatter: UIView, FutureResult: Any>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == VMatter, V.Result == Future<FutureResult>, V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        let bag = DisposeBag()

        bag += result.onResult { _ in disposable.dispose()
            bag.dispose()
        }

        return result
    }

    public func add<V: Viewable, VMatter: UIView>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == VMatter, V.Result == Disposable, V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }

    public func add<V: Viewable, Matter: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: (_ view: Matter.Matter) -> Void = { _ in }
    ) -> V.Result
    where
        V.Matter == Matter, V.Result == Disposable, V.Events == ViewableEvents, Matter.Matter == View,
        Matter.Result == Disposable, Matter.Events == ViewableEvents
    {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(
            events: ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        )

        let (viewableMatter, viewableResult, disposable) = materializeViewable(viewable: matter)

        onCreate(viewableMatter)

        return Disposer {
            result.dispose()
            disposable.dispose()
            viewableResult.dispose()
        }
    }

    public func add<V: Viewable, VMatter: UIView, SignalType: Any>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == VMatter, V.Result == Signal<SignalType>, V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(matter)

        let bag = DisposeBag()
        bag += disposable

        return Signal { callback in bag += result.onValue(callback)
            return bag
        }
    }
}

extension UIStackView {
    // swiftlint:disable large_tuple
    private func materializeArrangedViewable<V: Viewable, MatterView: UIView>(
        viewable: V
    ) -> (V.Matter, V.Result, Disposable) where V.Matter == MatterView, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        let (matter, result) = viewable.materialize(events: viewableEvents)

        addArrangedSubview(matter)

        wasAddedCallbacker.callAll()

        return (matter, result, Disposer { matter.removeFromSuperview() })
    }

    // swiftlint:enable large_tuple

    public func addArranged<V: Viewable, MatterView: UIView>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result where V.Matter == MatterView, V.Result == Disposable, V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeArrangedViewable(viewable: viewable)

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }

    public func addArranged<V: Viewable, MatterView: UIView, SignalType, SignalValue>(
        _ viewable: V,
        onCreate: (_ view: V.Matter) -> Void = defaultOnCreateClosure
    ) -> V.Result
    where V.Matter == MatterView, V.Result == CoreSignal<SignalType, SignalValue>, V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeArrangedViewable(viewable: viewable)

        onCreate(matter)

        return result.hold(disposable)
    }

    public func addArranged<V: Viewable, Matter: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: (_ view: Matter.Matter) -> Void = { _ in }
    ) -> V.Result
    where
        V.Matter == Matter, V.Result == Disposable, V.Events == ViewableEvents, Matter.Matter == View,
        Matter.Result == Disposable, Matter.Events == ViewableEvents
    {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(
            events: ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        )

        let (viewableMatter, viewableResult, disposable) = materializeArrangedViewable(viewable: matter)

        onCreate(viewableMatter)

        return Disposer {
            result.dispose()
            disposable.dispose()
            viewableResult.dispose()
        }
    }
}
