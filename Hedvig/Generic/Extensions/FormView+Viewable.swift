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
    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter, _ containerView: UIView) -> Void = { _, _ in }
    ) -> Disposable where
        V.Matter == UIView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let containerView = UIView()
        append(containerView)

        let disposable = containerView.add(viewable) { view in
            onCreate(view, containerView)
        }

        return disposable
    }

    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == SectionView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(viewable: viewable) { matter in
            self.append(matter)
        }

        onCreate(matter)

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }

    func prepend<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter, _ containerView: UIView) -> Void = { _, _ in }
    ) -> Disposable where
        V.Matter == UIView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let containerView = UIView()
        prepend(containerView)

        let disposable = containerView.add(viewable) { view in
            onCreate(view, containerView)
        }

        return disposable
    }

    func prepend<V: Viewable, Matter: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ view: Matter.Matter, _ containerView: UIView) -> Void = { _, _ in }
    ) -> Disposable where
        V.Matter == Matter,
        V.Result == Disposable,
        V.Events == ViewableEvents,
        Matter.Matter == UIView,
        Matter.Result == Disposable,
        Matter.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(events: ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        ))

        let bag = DisposeBag()

        bag += prepend(matter) { view, containerView in
            wasAddedCallbacker.callAll()
            onCreate(view, containerView)
        }

        return Disposer {
            result.dispose()
            bag.dispose()
        }
    }
}
