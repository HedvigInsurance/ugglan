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

extension SectionView {
    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ row: RowAndProvider<CoreSignal<Plain, ()>>) -> Void = { _ in }
    ) -> Disposable where V.Matter == RowView, V.Result == Disposable {
        let onSelectCallbacker = Callbacker<Void>()

        let (matter, result, disposable) = materializeViewable(
            viewable: viewable,
            onSelectCallbacker: onSelectCallbacker
        )

        let rowAndProvider = append(matter)

        let bag = DisposeBag()

        bag += rowAndProvider.onValue {
            onSelectCallbacker.callAll()
        }

        onCreate(rowAndProvider)

        return Disposer {
            bag.dispose()
            result.dispose()
            disposable.dispose()
        }
    }

    func append<V: Viewable, Matter: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ row: RowAndProvider<CoreSignal<Plain, ()>>) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == Matter,
        Matter.Matter == RowView,
        Matter.Result == Disposable,
        V.Result == Disposable {
        let onSelectCallbacker = Callbacker<Void>()
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(events: ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            onSelectCallbacker: onSelectCallbacker
        ))

        let bag = DisposeBag()

        bag += append(matter) { row in
            bag += row.onValue {
                onSelectCallbacker.callAll()
            }

            onCreate(row)
        }

        return Disposer {
            result.dispose()
            bag.dispose()
        }
    }
}
