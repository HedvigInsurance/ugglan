//
//  SectionView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

extension SectionView {
    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ row: RowAndProvider<CoreSignal<Plain, Void>>) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == RowView,
        V.Result == Disposable,
        V.Events == SelectableViewableEvents {
        let onSelectCallbacker = Callbacker<Void>()

        let (matter, result, disposable) = materializeViewable(
            viewable: viewable,
            onSelectCallbacker: onSelectCallbacker
        )

        let rowAndProvider = append(matter)

        let bag = DisposeBag()

        bag += rowAndProvider.lazyBindTo(callbacker: onSelectCallbacker)

        onCreate(rowAndProvider)

        return Disposer {
            self.remove(rowAndProvider)
            bag.dispose()
            result.dispose()
            disposable.dispose()
        }
    }

    func append<V: Viewable, View: RowView, SignalKind, SignalValue>(
        _ viewable: V,
        onCreate: @escaping (_ row: RowAndProvider<CoreSignal<Plain, Void>>) -> Void = { _ in }
    ) -> V.Result where
        V.Matter == View,
        V.Result == CoreSignal<SignalKind, SignalValue>,
        V.Events == SelectableViewableEvents {
        let onSelectCallbacker = Callbacker<Void>()

        let (matter, result, disposable) = materializeViewable(
            viewable: viewable,
            onSelectCallbacker: onSelectCallbacker
        )

        let rowAndProvider = append(matter)

        let bag = DisposeBag()

        bag += rowAndProvider.lazyBindTo(callbacker: onSelectCallbacker)

        onCreate(rowAndProvider)

        return result.hold(Disposer {
            self.remove(rowAndProvider)
            bag.dispose()
            disposable.dispose()
                   })
    }

    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ row: RowAndProvider<CoreSignal<Plain, Void>>) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == RowView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(
            viewable: viewable
        )

        let rowAndProvider = append(matter)

        let bag = DisposeBag()

        onCreate(rowAndProvider)

        return Disposer {
            self.remove(rowAndProvider)
            bag.dispose()
            result.dispose()
            disposable.dispose()
        }
    }

    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ row: SubviewOrderable) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == UIView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(
            viewable: viewable
        )

        let subviewOrderable = append(matter)

        let bag = DisposeBag()

        onCreate(subviewOrderable)

        return Disposer {
            subviewOrderable.removeFromSuperview()
            bag.dispose()
            result.dispose()
            disposable.dispose()
        }
    }

    func append<V: Viewable, View: UIView, SignalValue>(
        _ viewable: V,
        onCreate: @escaping (_ row: SubviewOrderable) -> Void = { _ in }
    ) -> V.Result where
        V.Matter == View,
        V.Result == Signal<SignalValue>,
        V.Events == ViewableEvents {
        let (matter, result, disposable) = materializeViewable(
            viewable: viewable
        )

        let subviewOrderable = append(matter)

        let bag = DisposeBag()

        onCreate(subviewOrderable)

        return result.hold(Disposer {
            subviewOrderable.removeFromSuperview()
            bag.dispose()
            disposable.dispose()
        })
    }

    func append<V: Viewable, Matter: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ row: RowAndProvider<CoreSignal<Plain, Void>>) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == Matter,
        Matter.Matter == RowView,
        Matter.Result == Disposable,
        Matter.Events == SelectableViewableEvents,
        V.Result == Disposable,
        V.Events == SelectableViewableEvents {
        let onSelectCallbacker = Callbacker<Void>()
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(events: SelectableViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            onSelectCallbacker: onSelectCallbacker
        ))

        let bag = DisposeBag()

        bag += append(matter) { row in
            bag += row.lazyBindTo(callbacker: onSelectCallbacker)
            onCreate(row)
        }

        return Disposer {
            result.dispose()
            bag.dispose()
        }
    }
}
