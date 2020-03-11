//
//  RowView+Viewable.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-30.
//

import Flow
import Form
import Foundation
import UIKit

struct Fish {
    let color: UIColor
}

public extension RowView {
    func append<V: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: @escaping (_ view: View) -> Void = { _ in }
    ) -> Disposable where
        V.Matter == View,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(events: ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        ))

        let bag = DisposeBag()

        append(matter)
        onCreate(matter)

        return Disposer {
            result.dispose()
            bag.dispose()
            matter.removeFromSuperview()
        }
    }
}
