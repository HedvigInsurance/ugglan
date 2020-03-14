//
//  FormView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

extension FormView {
    func prepend<V: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == View,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable) { matter in
            self.prepend(matter)
        }

        onCreate(matter)

        return Disposer {
            matter.removeFromSuperview()
            result.dispose()
            disposable.dispose()
        }
    }

    func prepend<V: Viewable, View: UIView, SignalValue>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) -> V.Result where
        V.Matter == View,
        V.Result == Signal<SignalValue>,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable) { matter in
            self.prepend(matter)
        }

        onCreate(matter)

        return result.hold(Disposer {
            matter.removeFromSuperview()
            disposable.dispose()
        })
    }

    func append<V: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == View,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable) { matter in
            self.append(matter)
        }

        onCreate(matter)

        return Disposer {
            matter.removeFromSuperview()
            result.dispose()
            disposable.dispose()
        }
    }

    func append<V: Viewable, View: UIView, SignalValue>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) -> V.Result where
        V.Matter == View,
        V.Result == Signal<SignalValue>,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable) { matter in
            self.append(matter)
        }

        onCreate(matter)

        return result.hold(Disposer {
            matter.removeFromSuperview()
            disposable.dispose()
            })
    }

    func append<V: Viewable, View: UIView, SignalKind, SignalValue>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) -> V.Result where
        V.Matter == View,
        V.Result == CoreSignal<SignalKind, SignalValue>,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable) { matter in
            self.append(matter)
        }

        onCreate(matter)

        return result.hold(Disposer {
            matter.removeFromSuperview()
            disposable.dispose()
            })
    }

    func prepend<V: Viewable, Matter: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: @escaping (_ view: Matter.Matter) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == Matter,
        V.Result == Disposable,
        V.Events == ViewableEvents,
        Matter.Matter == View,
        Matter.Result == Disposable,
        Matter.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(events: ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        ))

        let bag = DisposeBag()

        bag += prepend(matter) { view in
            wasAddedCallbacker.callAll()
            onCreate(view)
        }

        return Disposer {
            result.dispose()
            bag.dispose()
        }
    }

    func append<V: Viewable, Matter: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: @escaping (_ view: Matter.Matter) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == Matter,
        V.Result == Disposable,
        V.Events == ViewableEvents,
        Matter.Matter == View,
        Matter.Result == Disposable,
        Matter.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(events: ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        ))

        let bag = DisposeBag()

        bag += append(matter) { view in
            wasAddedCallbacker.callAll()
            onCreate(view)
        }

        return Disposer {
            result.dispose()
            bag.dispose()
        }
    }
}
